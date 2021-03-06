import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/blocs/bloc_index.dart';
import 'package:flutter_wanandroid/common/component_index.dart';
import 'package:flutter_wanandroid/data/net/dio_util.dart';
import 'package:flutter_wanandroid/pages/page_index.dart';

Future<void> main() async {
  return runApp(BlocProvider<ApplicationBloc>(
    bloc: ApplicationBloc(),
    child: BlocProvider(child: MyApp(), bloc: MainBloc()),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  Locale _locale;
  Color _themeColor = ColorT.gray_33;

  @override
  void initState() {
    super.initState();
    setLocalizedValues(localizedValues);
    _init();
    _initAsync();
    _initListener();
  }

  void _init() {
    DioUtil.openDebug();//打开debug模式.
    Options options = DioUtil.getDefOptions();
    options.baseUrl = Constant.SERVER_ADDRESS;
    HttpConfig config = new HttpConfig(options: options);
    DioUtil().setConfig(config);
  }

  void _initListener() {
    final ApplicationBloc bloc = BlocProvider.of<ApplicationBloc>(context);
    bloc.appEventStream.listen((value) {
      _loadLocale();
    });
  }

  void _initAsync() async {
    await SpUtil.getInstance();
    if (!mounted) return;
    _loadLocale();
  }

  void _loadLocale() {
    setState(() {
      LanguageModel model = SpHelper.getLanguageModel();
      if (model != null) {
        LogUtil.e('LanguageModel: ' + model.toString());
        _locale = new Locale(model.languageCode, model.countryCode);
      } else {
        _locale = null;
      }

      String _colorKey = SpUtil.getString(Constant.KEY_THEME_COLOR);
      if (ObjectUtil.isEmpty(_colorKey)) {
        _colorKey = 'gray';
      }
      _themeColor = themeColorMap[_colorKey];
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      routes: {
        '/MainPage': (ctx) => MainPage(),
      },
      home: new SplashPage(),
      theme: ThemeData.light().copyWith(
        primaryColor: _themeColor,
        accentColor: _themeColor,
        indicatorColor: Colors.white,
      ),
      locale: _locale,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        CustomLocalizations.delegate
      ],
      supportedLocales: CustomLocalizations.supportedLocales,
    );
  }
}
