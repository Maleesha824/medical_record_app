import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medical_models.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';

class AddRecordScreen extends StatefulWidget { const AddRecordScreen({super.key}); @override State<AddRecordScreen> createState()=>_AddRecordScreenState(); }
class _AddRecordScreenState extends State<AddRecordScreen>{
  final title=TextEditingController(), disease=TextEditingController(), doctor=TextEditingController(), notes=TextEditingController(), prescription=TextEditingController();
  DateTime date=DateTime.now(); String? imagePath;
  Future<void> save() async { if(disease.text.trim().isEmpty && title.text.trim().isEmpty) return; await DatabaseService.instance.addRecord(MedicalRecord(title:title.text.trim().isEmpty?'Medical Record':title.text.trim(), disease:disease.text.trim(), date:DateFormat('yyyy-MM-dd').format(date), doctor:doctor.text.trim(), notes:notes.text.trim(), prescriptionText:prescription.text.trim(), imagePath:imagePath)); if(mounted) Navigator.pop(context,true); }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Add Medical Record')),body:ListView(padding:const EdgeInsets.all(18),children:[
    _f(title,'Record title',Icons.description),_f(disease,'Disease / condition',Icons.healing),_f(doctor,'Doctor name (optional)',Icons.person),_f(notes,'Notes',Icons.notes,max:4),_f(prescription,'Prescription / receipt text',Icons.receipt_long,max:5),
    ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.calendar_today),title:const Text('Record date'),subtitle:Text(DateFormat('dd MMM yyyy').format(date)),onTap:()async{final d=await showDatePicker(context:context,firstDate:DateTime(2000),lastDate:DateTime(2100),initialDate:date);if(d!=null)setState(()=>date=d);}),
    const SizedBox(height:6),
    OutlinedButton.icon(onPressed:()async{final path=await ImageService.pickPrescriptionImage();if(path!=null)setState(()=>imagePath=path);},icon:const Icon(Icons.image_outlined),label:Text(imagePath==null?'Attach prescription image':'Change prescription image')),
    if(imagePath!=null)...[const SizedBox(height:12),ClipRRect(borderRadius:BorderRadius.circular(16),child:Image.file(File(imagePath!),height:220,fit:BoxFit.cover)),TextButton.icon(onPressed:()=>setState(()=>imagePath=null),icon:const Icon(Icons.delete_outline),label:const Text('Remove image'))],
    const SizedBox(height:12),FilledButton.icon(onPressed:save,icon:const Icon(Icons.save),label:const Text('Save Medical Record'))
  ]));
  Widget _f(TextEditingController c,String l,IconData i,{int max=1})=>Padding(padding:const EdgeInsets.only(bottom:12),child:TextField(controller:c,maxLines:max,decoration:InputDecoration(labelText:l,prefixIcon:Icon(i))));
}
