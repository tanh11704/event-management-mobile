import 'package:event_management/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_event.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_state.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? phoneNumber;
  String? password;
  String? confirmPassword;
  int? unitId;

  @override
  void initState() {
    super.initState();
    // Chỉ fetch units 1 lần khi khởi tạo form
    context.read<RegisterBloc>().add(const RegisterGetUnits());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
        }
        if (state is RegisterFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is RegisterLoading;
        final unitsLoaded = state is RegisterUnitsLoaded ? state : null;

        return Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Họ tên'),
                onSaved: (v) => name = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (v) => email = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                onSaved: (v) => phoneNumber = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                onSaved: (v) => password = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                ),
                obscureText: true,
                onSaved: (v) => confirmPassword = v,
                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
              ),
              if (unitsLoaded != null)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Loại tài khoản',
                  ),
                  initialValue: unitsLoaded.selectedAccountTypeId,
                  items: unitsLoaded.accountTypes
                      .map<DropdownMenuItem<int>>(
                        (UnitEntity u) => DropdownMenuItem(
                          value: u.id,
                          child: Text(u.unitName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      unitId = null;
                    });
                    context.read<RegisterBloc>().add(
                      RegisterAccountTypeChanged(value!),
                    );
                  },
                  validator: (v) => v == null ? 'Bắt buộc' : null,
                ),
              if (unitsLoaded != null &&
                  unitsLoaded.selectedAccountTypeId != null)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Đơn vị / Lớp'),
                  initialValue: unitId,
                  items: unitsLoaded.filteredUnits
                      .map<DropdownMenuItem<int>>(
                        (UnitEntity u) => DropdownMenuItem(
                          value: u.id,
                          child: Text(u.unitName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => unitId = value),
                  validator: (v) => v == null ? 'Bắt buộc' : null,
                ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!isLoading)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        context.read<RegisterBloc>().add(
                          RegisterSubmitted(
                            name: name!,
                            email: email!,
                            phoneNumber: phoneNumber!,
                            password: password!,
                            confirmPassword: confirmPassword!,
                            unitId: unitId,
                          ),
                        );
                      }
                    },
                    child: const Text('Đăng ký'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
