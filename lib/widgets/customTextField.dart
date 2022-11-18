import 'package:flutter/material.dart';

class InvoiceTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final double? width;
  final String? title;
  final TextInputType? inputType;
  final bool? isEnd;

  const InvoiceTextField(
      {Key? key,
      this.controller,
      this.hintText,
      this.width,
      this.title,
      this.inputType,
      this.isEnd})
      : super(key: key);

  @override
  State<InvoiceTextField> createState() => _InvoiceTextFieldState();
}

class _InvoiceTextFieldState extends State<InvoiceTextField> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: SizedBox(
        width: widget.width,
        height: 60.0,
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              widget.isEnd! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 15.0,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Container(
              height: 35.0,
              width: widget.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: FocusScope(
                  onFocusChange: (v) {
                    setState(() {
                      isSelected = v;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: TextFormField(
                      controller: widget.controller,
                      keyboardType: widget.inputType,
                      //style: TextStyle(fontSize: 10.0, color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration.collapsed(
                        hintText: widget.hintText,
                        focusColor: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final String? hintText;
  final bool? isObscure;
  final TextInputType? inputType;
  final Widget? suffixIcon;

  const AuthTextField(
      {Key? key,
      this.controller,
      this.prefixIcon,
      this.hintText,
      this.isObscure,
      this.inputType,
      this.suffixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 20.0,
      decoration: const BoxDecoration(
          // color: Colors.grey.withOpacity(0.3),
          // borderRadius: BorderRadius.circular(30.0),
          ),
      padding: const EdgeInsets.all(8.0),
      // margin: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure!,
        keyboardType: inputType,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(
                width: 1.0,
              )),
          prefixIcon: prefixIcon,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 2,
            minHeight: 2,
          ),
          suffixIcon: suffixIcon,
          focusColor: Theme.of(context).primaryColor,
          hintText: hintText,
          labelText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? title;
  final TextInputType? inputType;

  const CustomTextField(
      {Key? key, this.controller, this.hintText, this.title, this.inputType})
      : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: FocusScope(
            onFocusChange: (v) {
              setState(() {
                isSelected = v;
              });
            },
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.inputType,
              // expands: true,
              maxLines: null,
              decoration: InputDecoration(
                //icon: Icon(Icons.person),
                hintText: widget.hintText,
                labelText: widget.title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
