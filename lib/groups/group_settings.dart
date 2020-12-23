import 'package:csocsort_szamla/gradient_button.dart';
import 'package:csocsort_szamla/groups/change_group_currency_dialog.dart';
import 'package:csocsort_szamla/groups/rename_group_dialog.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share/share.dart';

import 'package:csocsort_szamla/config.dart';
import 'package:csocsort_szamla/http_handler.dart';
import '../error_message.dart';
import 'group_members.dart';

class GroupSettings extends StatefulWidget {
  @override
  _GroupSettingState createState() => _GroupSettingState();
}

class _GroupSettingState extends State<GroupSettings> {
  Future<String> _invitation;
  Future<bool> _isUserAdmin;

  Future<String> _getInvitation() async {
    try {
      http.Response response = await httpGet(
          uri: '/groups/' + currentGroupId.toString(),
          context: context);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data']['invitation'];

    } catch (_) {
      throw _;
    }
  }
  Future<bool> _getIsUserAdmin() async {
    try {
      http.Response response = await httpGet(
          uri: '/groups/' + currentGroupId.toString() + '/member',
          context: context, useCache: false);
      Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded['data']['is_admin'] == 1;
    } catch (_) {
      throw _;
    }
  }

  @override
  void initState() {
    _invitation = null;
    _invitation = _getInvitation();
    _isUserAdmin = null;
    _isUserAdmin = _getIsUserAdmin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await deleteCache(uri: '/groups');
        setState(() {
          _invitation = null;
          _invitation = _getInvitation();
          _isUserAdmin = null;
          _isUserAdmin = _getIsUserAdmin();
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          children: <Widget>[
            FutureBuilder(
                future: _isUserAdmin,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Visibility(
                            visible: snapshot.data,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        'rename_group'.tr(),
                                        style:
                                            Theme.of(context).textTheme.headline6,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                        child: Text(
                                      'rename_group_explanation'.tr(),
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                      textAlign: TextAlign.center,
                                    )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GradientButton(
                                          child: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSecondary,),
                                          onPressed: (){
                                            showDialog(context: context, child: RenameGroupDialog());
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: snapshot.data,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        'change_group_currency'.tr(),
                                        style:
                                        Theme.of(context).textTheme.headline6,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                        child: Text(
                                          'change_group_currency_explanation'.tr(),
                                          style:
                                          Theme.of(context).textTheme.subtitle2,
                                          textAlign: TextAlign.center,
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GradientButton(
                                          child: Icon(Icons.monetization_on, color: Theme.of(context).colorScheme.onSecondary,),
                                          onPressed: (){
                                            showDialog(context: context, child: ChangeGroupCurrencyDialog());
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'invitation'.tr(),
                                    style: Theme.of(context).textTheme.headline6,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                      child: Text(
                                    'invitation_explanation'.tr(),
                                    style: Theme.of(context).textTheme.subtitle2,
                                    textAlign: TextAlign.center,
                                  )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  FutureBuilder(
                                    future: _invitation,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasData) {
                                          return Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                GradientButton(
                                                  onPressed: () {
                                                    Share.share(
                                                        'http://www.lenderapp.net/join/' +
                                                            snapshot.data,
                                                        subject:
                                                            'invitation_to_lender'
                                                                .tr());
                                                  },
                                                  child: Icon(
                                                    Icons.share,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return ErrorMessage(
                                            error: snapshot.error.toString(),
                                            locationOfError: 'balances',
                                            callback: (){
                                              setState(() {
                                                _invitation = null;
                                                _invitation = _getInvitation();
                                              });
                                            },
                                          );
                                        }
                                      }
                                      return Center(
                                          child: CircularProgressIndicator());
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GroupMembers(),
                        ],
                      );
                    } else {
                      return ErrorMessage(
                        error: snapshot.error.toString(),
                        locationOfError: 'balances',
                        callback: (){
                          setState(() {
                            _isUserAdmin = null;
                            _isUserAdmin = _getIsUserAdmin();
                          });
                        },
                      );
                    }
                  }
                  return LinearProgressIndicator();
                }),
          ],
        ),
      ),
    );
  }
}
