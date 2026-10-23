import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medical_models.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class AddMedicationScreen extends StatefulWidget { const AddMedicationScreen({super.key}); @override State<AddMedicationScreen> createState()=>_AddMedicationScreenState(); }
class _AddMedicationScreenState extends State<AddMedicationScreen>{
  final name=TextEditingController(), dosage=TextEditingController(), disease=TextEditingController(), duration=TextEditingController(text:'7'), stock=TextEditingController(text:'20'), threshold=TextEditingController(text:'3'), custom=TextEditingController(text:'6');
  DateTime start=DateTime.now(); TimeOfDay time=const TimeOfDay(hour:8,minute:0); String frequency='Every 8 hours';
  Future<void> save()async{if(name.text.trim().isEmpty)return;final id=await DatabaseService.instance.addMedication(Medication(name:name.text.trim(),dosage:dosage.text.trim(),disease:disease.text.trim(),startDate:DateFormat('yyyy-MM-dd').format(start),frequency:frequency,firstTime:'${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}',durationDays:int.tryParse(duration.text)??7,stock:int.tryParse(stock.text)??0,lowStockThreshold:int.tryParse(threshold.text)??3,customIntervalHours:int.tryParse(custom.text)??6));
    final first=DateTime(start.year,start.month,start.day,time.hour,time.minute); final interval=_interval(); await NotificationService.scheduleMedicine(medicationId:id,name:name.text.trim(),dosage:dosage.text.trim(),firstDose:first,durationDays:int.tryParse(duration.text)??7,interval:interval); if(mounted)Navigator.pop(context,true);}
  Duration _interval(){switch(frequency){case'Every 6 hours':return const Duration(hours:6);case'Every 8 hours':return const Duration(hours:8);case'Every 12 hours':return const Duration(hours:12);case'Once daily':return const Duration(days:1);case'Every 2 days':return const Duration(days:2);default:return Duration(hours:int.tryParse(custom.text)??6);}}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Add Medication')),body:ListView(padding:const EdgeInsets.all(18),children:[_f(name,'Medicine name',Icons.medication),_f(dosage,'Dosage',Icons.scale),_f(disease,'For disease / condition',Icons.healing),
    ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.calendar_today),title:const Text('Start date'),subtitle:Text(DateFormat('dd MMM yyyy').format(start)),onTap:()async{final d=await showDatePicker(context:context,firstDate:DateTime.now().subtract(const Duration(days:3650)),lastDate:DateTime(2100),initialDate:start);if(d!=null)setState(()=>start=d);}),
    ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.alarm),title:const Text('First dose time'),subtitle:Text(time.format(context)),onTap:()async{final t=await showTimePicker(context:context,initialTime:time);if(t!=null)setState(()=>time=t);}),
    DropdownButtonFormField<String>(initialValue:frequency,decoration:const InputDecoration(labelText:'Frequency'),items:const ['Every 6 hours','Every 8 hours','Every 12 hours','Once daily','Every 2 days','Custom'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>frequency=v!)),
    if(frequency=='Custom')_f(custom,'Custom interval (hours)',Icons.timer),
    const SizedBox(height:10),Row(children:[Expanded(child:_f(duration,'Duration (days)',Icons.timelapse)),const SizedBox(width:10),Expanded(child:_f(stock,'Current stock',Icons.inventory_2))]),_f(threshold,'Low stock warning at',Icons.warning_amber),
    Card(child:const Padding(padding:EdgeInsets.all(12),child:Text('The app schedules exact-time medicine reminders for the selected duration. Android exact-alarm permission is requested when the app starts.'))),const SizedBox(height:10),FilledButton.icon(onPressed:save,icon:const Icon(Icons.alarm_add),label:const Text('Save & Schedule Reminders'))]));
  Widget _f(TextEditingController c,String l,IconData i)=>Padding(padding:const EdgeInsets.only(bottom:12),child:TextField(controller:c,keyboardType:l.contains('hours')||l.contains('days')||l.contains('stock')||l.contains('warning')?TextInputType.number:null,decoration:InputDecoration(labelText:l,prefixIcon:Icon(i))));
}
