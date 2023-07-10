// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Professor {
  final String id;
  String nome;
  String disciplina;
  int idade;

  Professor({
    required this.id,
    required this.nome,
    required this.disciplina,
    required this.idade,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'disciplina': disciplina,
      'idade': idade,
    };
  }

  factory Professor.fromMap(Map<String, dynamic> map) {
    return Professor(
      id: map['id'],
      nome: map['nome'],
      disciplina: map['disciplina'],
      idade: map['idade'],
    );
  }
}

class CadastroProfessorPage extends StatefulWidget {
  const CadastroProfessorPage({Key? key}) : super(key: key);

  @override
  _CadastroProfessorPageState createState() => _CadastroProfessorPageState();
}

class _CadastroProfessorPageState extends State<CadastroProfessorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _disciplinaController = TextEditingController();
  final _idadeController = TextEditingController();
  final CollectionReference _professorCollection =
      FirebaseFirestore.instance.collection('professores');

  final List<Professor> professores = [];
  Professor? selectedProfessor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro e Listagem de Professores'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite o nome do professor';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _disciplinaController,
                    decoration: InputDecoration(labelText: 'Disciplina'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite a disciplina do professor';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _idadeController,
                    decoration: InputDecoration(labelText: 'Idade'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite a idade do professor';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Idade inválida';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (selectedProfessor != null) {
                          // Editar o professor selecionado
                          selectedProfessor!.nome = _nomeController.text;
                          selectedProfessor!.disciplina =
                              _disciplinaController.text;
                          selectedProfessor!.idade =
                              int.parse(_idadeController.text);
                          _professorCollection
                              .doc(selectedProfessor!.id)
                              .update(selectedProfessor!.toMap());
                          selectedProfessor = null;
                        } else {
                          // Cadastrar um novo professor
                          Professor newProfessor = Professor(
                            id: DateTime.now().toString(),
                            nome: _nomeController.text,
                            disciplina: _disciplinaController.text,
                            idade: int.parse(_idadeController.text),
                          );
                          _professorCollection.add(newProfessor.toMap());
                        }

                        _nomeController.clear();
                        _disciplinaController.clear();
                        _idadeController.clear();

                        setState(() {});
                      }
                    },
                    child: Text(
                        selectedProfessor != null ? 'Salvar' : 'Cadastrar'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.0),
            Text(
              'Lista de Professores:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            StreamBuilder<QuerySnapshot>(
              stream: _professorCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Erro ao carregar professores');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final List<QueryDocumentSnapshot> documents =
                    snapshot.data!.docs;
                professores.clear();
                for (var doc in documents) {
                  professores.add(
                      Professor.fromMap(doc.data() as Map<String, dynamic>));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: professores.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(professores[index].nome),
                      subtitle: Text(professores[index].disciplina),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editProfessor(professores[index]);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteProfessor(professores[index]);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editProfessor(Professor professor) {
    setState(() {
      selectedProfessor = professor;
      _nomeController.text = professor.nome;
      _disciplinaController.text = professor.disciplina;
      _idadeController.text = professor.idade.toString();
    });
  }

  void _deleteProfessor(Professor professor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmação'),
        content: Text('Deseja excluir este professor?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _professorCollection.doc(professor.id).delete();
              Navigator.pop(context);
            },
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
