import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share/share.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/auth/login_or_register_page.dart';
import 'group_members.dart';
import 'package:csocsort_szamla/main.dart';
import 'package:csocsort_szamla/future_success_dialog.dart';

class GroupSettings extends StatefulWidget {
  @override
  _GroupSettingState createState() => _GroupSettingState();
}

class _GroupSettingState extends State<GroupSettings> {
  Future<String> _invitation;
  Future<bool> _isUserAdmin;

  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _groupNameController = TextEditingController();

  var _nicknameFormKey = GlobalKey<FormState>();
  var _groupNameFormKey = GlobalKey<FormState>();

  Future<String> _getInvitation() async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/groups/'+currentGroupId.toString(), headers: header);
      if(response.statusCode==200){
        Map<String, dynamic> decoded = jsonDecode(response.body);
        return decoded['data']['invitations'][0]['token'];
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  Future<bool> _updateNickname(String nickname) async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };
      Map<String, dynamic> body = {
        "nickname": nickname
      };

      String bodyEncoded = jsonEncode(body);
      http.Response response = await http.put(APPURL+'/groups/'+currentGroupId.toString()+'/members', headers: header, body: bodyEncoded);
      if(response.statusCode==204){
        return true;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }
  Future<bool> _updateGroupName(String groupName) async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };
      Map<String, dynamic> body = {
        "name": groupName
      };


      String bodyEncoded = jsonEncode(body);
      http.Response response = await http.put(APPURL+'/groups/'+currentGroupId.toString(), headers: header, body: bodyEncoded);
      if(response.statusCode==200){
        Map<String, dynamic> decoded = jsonDecode(response.body);
        currentGroupName=decoded['group_name'];
        currentGroupId=decoded['group_id'];
        return true;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }

  Future<bool> _getIsUserAdmin() async {
    try{
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "+apiToken
      };

      http.Response response = await http.get(APPURL+'/groups/'+currentGroupId.toString()+'/member', headers: header);
      if(response.statusCode==200){
        Map<String, dynamic> decoded = jsonDecode(response.body);
        return decoded['data']['is_admin']==1;
      }else{
        Map<String, dynamic> error = jsonDecode(response.body);
        if(error['error']=='Unauthenticated.'){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginOrRegisterPage()), (r)=>false);
        }
        throw error['error'];
      }
    }catch(_){
      throw _;
    }
  }


  @override
  void initState() {
    _invitation=null;
    _invitation=_getInvitation();
    _isUserAdmin=null;
    _isUserAdmin=_getIsUserAdmin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ListView(
//      padding: EdgeInsets.all(15),
        children: <Widget>[
          Form(
            key: _nicknameFormKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    Text('new_nickname'.tr(), style: Theme.of(context).textTheme.headline6,),
                    SizedBox(height: 40,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                            validator: (value){
                              if(value.isEmpty){
                                return 'field_empty'.tr();
                              }
                              if(value.length<1){
                                return 'minimal_length'.tr(args: ['1']);
                              }
                              return null;
                            },
                            controller: _nicknameController,
                            decoration: InputDecoration(
                              hintText: currentUser.split('#')[0],
                              labelText: 'nickname'.tr(),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                                //  when the TextFormField in unfocused
                              ) ,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                              ),

                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(15),
                            ],
                            style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                            cursorColor: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        SizedBox(width: 10,),
                        RaisedButton(
                          onPressed: (){
                            if(_nicknameFormKey.currentState.validate()){
                              FocusScope.of(context).unfocus();
                              String nickname = _nicknameController.text[0].toUpperCase()+_nicknameController.text.substring(1);
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  child:
                                  FutureSuccessDialog(
                                    future: _updateNickname(nickname),
                                    onDataTrue: (){
                                      _nicknameController.text='';
                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainPage()), (r)=>false);
                                    },
                                    dataTrueText: 'nickname_scf',
                                  )
                              );
                            }

                          },
                          child: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary,),
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
          FutureBuilder(
            future: _isUserAdmin,
            builder: (context, snapshot){
              if(snapshot.connectionState==ConnectionState.done){
                if(snapshot.hasData){
                  return Column(
                    children: <Widget>[
                      Visibility(
                        visible: snapshot.data,
                        child: Form(
                          key: _groupNameFormKey,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: <Widget>[
                                  Text('rename_group'.tr(), style: Theme.of(context).textTheme.headline6,),
                                  SizedBox(height: 40,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Flexible(
                                        child: TextFormField(
                                          validator: (value){
                                            if(value.isEmpty){
                                              return 'field_empty'.tr();
                                            }
                                            if(value.length<1){
                                              return 'minimal_length'.tr(args: ['1']);
                                            }
                                            return null;
                                          },
                                          controller: _groupNameController,
                                          decoration: InputDecoration(
                                            labelText: 'new_name'.tr(),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2),
                                            ) ,
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                            ),

                                          ),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(20),
                                          ],
                                          style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText1.color),
                                          cursorColor: Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      RaisedButton(
                                        onPressed: (){
                                          if(_groupNameFormKey.currentState.validate()){
                                            FocusScope.of(context).unfocus();
                                            String _groupName = _groupNameController.text;
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                child:
                                                FutureSuccessDialog(
                                                  future: _updateGroupName(_groupName),
                                                  dataTrueText: 'nickname_scf',
                                                  onDataTrue: (){
                                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainPage()), (r)=>false);
                                                    _groupNameController.text='';
                                                  },
                                                )
                                            );
                                          }
                                        },
                                        child: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary,),
                                        color: Theme.of(context).colorScheme.secondary,
                                      )
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: <Widget>[
                              Text('invitation'.tr(), style: Theme.of(context).textTheme.headline6,),
                              SizedBox(height: 40,),
                              FutureBuilder(
                                future: _invitation,
                                builder: (context, snapshot){
                                  if(snapshot.connectionState==ConnectionState.done){
                                    if(snapshot.hasData){
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            child: GestureDetector(
                                              onTap: (){
                                                Share.share('http://www.lenderapp.net/join/'+snapshot.data, subject: 'invitation_to_lender'.tr());
                                              },
                                              child: Text(snapshot.data, style: Theme.of(context).textTheme.bodyText1,),
                                            ),
                                          ),
                                          RaisedButton(
                                            onPressed: (){
                                              Share.share('http://www.lenderapp.net/join/'+snapshot.data, subject: 'invitation_to_lender'.tr());
                                            },
                                            child: Icon(Icons.share, color: Theme.of(context).colorScheme.onSecondary,),
                                            color: Theme.of(context).colorScheme.secondary,
                                          )
                                        ],
                                      );
                                    }else{
                                      return InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(32.0),
                                            child: Text(snapshot.error.toString()),
                                          ),
                                          onTap: (){
                                            setState(() {
                                              _invitation=null;
                                              _invitation=_getInvitation();
                                            });
                                          }
                                      );
                                    }
                                  }
                                  return Center(child: CircularProgressIndicator());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }
              return LinearProgressIndicator();

            }
          ),
          GroupMembers(),
        ],
      ),
    );
  }
}
