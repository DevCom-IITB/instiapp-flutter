import 'package:InstiApp/src/bloc_provider.dart';
import 'package:flutter/material.dart';

class TitleWithBackButton extends StatefulWidget {
  final Widget child;
  final bool hasBackButton;
  final EdgeInsets contentPadding;

  TitleWithBackButton(
      {required this.child,
      this.hasBackButton = true,
      this.contentPadding = const EdgeInsets.all(28.0)});

  @override
  _TitleWithBackButtonState createState() => _TitleWithBackButtonState();
}

class _TitleWithBackButtonState extends State<TitleWithBackButton> {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)?.bloc;
    var theme = Theme.of(context);

    return StreamBuilder(
      stream: bloc?.navigatorObserver.secondTopRouteName,
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        bool currHasBackButton = (theme.platform == TargetPlatform.iOS ||
                theme.platform == TargetPlatform.macOS) &&
            widget.hasBackButton &&
            snapshot.data != null &&
            Navigator.of(context).canPop();
        return Stack(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: widget.contentPadding
                  .add(EdgeInsets.only(top: (currHasBackButton ? 8 : 0))),
              child: widget.child,
            ),
            currHasBackButton
                ? InkWell(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        BackButtonIcon(),
                        Text("${snapshot.data}"),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).maybePop();
                    },
                  )
                : Container(
                    height: 0,
                    width: 0,
                  ),
          ],
        );
      },
    );
  }
}
