import 'package:flutter/material.dart';
import 'package:logistics_pro/features/admin/data/models/persona_model.dart';
import 'package:logistics_pro/features/admin/domain/usecases/create_persona_usecase.dart';
import 'package:logistics_pro/features/admin/domain/usecases/get_personal_usecase.dart';
import 'package:logistics_pro/features/admin/domain/usecases/update_persona_usecase.dart';

enum PersonState {initial, loading, success, error}

class PersonaController extends ChangeNotifier{

  // Hacer la referencia al domain a los usecases 
  final CreatePersonaUsecase createPersonaUsecase;
  final GetPersonalUsecase getPersonalUsecase;
  final UpdatePersonaUsecase updatePersonaUsecase;

  PersonaController({
  required this.createPersonaUsecase, 
  required this.getPersonalUsecase,
  required this.updatePersonaUsecase,
  });


  PersonState _personState = PersonState.initial;

  List<PersonaModel> _personaList = [];
  String? _errorMessage;

  PersonState get status => _personState;
  List<PersonaModel> get personaList => _personaList;
  String? get errorMessage => _errorMessage;
  bool get isLoaded => _personState == PersonState.success;

  //Llama a la lista de empleados desde usecase 
  Future<void> fetchPersonal() async{
    _personState = PersonState.loading;
    notifyListeners();
    try{
      _personaList = await getPersonalUsecase();
      _personState = PersonState.success;

    }catch(e){
      _personState = PersonState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  //Llama al registro de datos del usecase
  Future<bool> registrarEmpleado(PersonaModel persona) async{
    _personState = PersonState.loading;
    notifyListeners();
    try{
      await createPersonaUsecase(persona);
      _personState = PersonState.success;
      await fetchPersonal(); //Refrescar la lista global
      return true;
    }catch(e){
      _personState = PersonState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updatePerson(PersonaModel person) async{
    _personState = PersonState.loading;
    notifyListeners();
    try{
      await updatePersonaUsecase(person);
      _personState = PersonState.success;
      await fetchPersonal(); //Refrescar la lista global
    }catch(e){
      _personState = PersonState.error;
      _errorMessage = e.toString().replaceAll('Exception:', '');
    }
    notifyListeners();
  }
    
  void resetState(){
    _personState = PersonState.initial;
  }
  
  void consumeError(){
    _errorMessage = null;
  }


}