// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Escola {
  final String id;
  String nome;
  String endereco;
  String telefone;

  Escola({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.telefone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'telefone': telefone,
    };
  }

  factory Escola.fromMap(Map<String, dynamic> map) {
    return Escola(
      id: map['id'],
      nome: map['nome'],
      endereco: map['endereco'],
      telefone: map['telefone'],
    );
  }
}

class RegistraEscolaPage extends StatefulWidget {
  const RegistraEscolaPage({Key? key}) : super(key: key);

  @override
  _RegistraEscolaPageState createState() => _RegistraEscolaPageState();
}

class _RegistraEscolaPageState extends State<RegistraEscolaPage> {
  final _formKey = GlobalKey<FormState>();
  final _escolanomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final CollectionReference _escolaCollection =
      FirebaseFirestore.instance.collection('escolas');

  final List<Escola> escolas = [];
  Escola? selectedEscola;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro e Listagem de Escolas'),
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
                    controller: _escolanomeController,
                    decoration: InputDecoration(labelText: 'Nome da Escola'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite o nome da escola';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _enderecoController,
                    decoration: InputDecoration(labelText: 'Endereço'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite o endereço da escola';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _telefoneController,
                    decoration: InputDecoration(labelText: 'Telefone'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite o telefone da escola';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (selectedEscola != null) {
                          // Editar a escola selecionada
                          selectedEscola!.nome = _escolanomeController.text;
                          selectedEscola!.endereco = _enderecoController.text;
                          selectedEscola!.telefone = _telefoneController.text;
                          _escolaCollection
                              .doc(selectedEscola!.id)
                              .update(selectedEscola!.toMap());
                          selectedEscola = null;
                        } else {
                          // Cadastrar uma nova escola
                          Escola newEscola = Escola(
                            id: DateTime.now().toString(),
                            nome: _escolanomeController.text,
                            endereco: _enderecoController.text,
                            telefone: _telefoneController.text,
                          );
                          _escolaCollection.add(newEscola.toMap());
                        }

                        _escolanomeController.clear();
                        _enderecoController.clear();
                        _telefoneController.clear();

                        setState(() {});
                      }
                    },
                    child:
                        Text(selectedEscola != null ? 'Salvar' : 'Cadastrar'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.0),
            Text(
              'Lista de Escolas:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            StreamBuilder<QuerySnapshot>(
              stream: _escolaCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Erro ao carregar escolas');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final List<QueryDocumentSnapshot> documents =
                    snapshot.data!.docs;
                escolas.clear();
                for (var doc in documents) {
                  escolas
                      .add(Escola.fromMap(doc.data() as Map<String, dynamic>));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: escolas.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(escolas[index].nome),
                      subtitle: Text(escolas[index].endereco),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editEscola(escolas[index]);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteEscola(escolas[index]);
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

  void _editEscola(Escola escola) {
    setState(() {
      selectedEscola = escola;
      _escolanomeController.text = escola.nome;
      _enderecoController.text = escola.endereco;
      _telefoneController.text = escola.telefone;
    });
  }

  void _deleteEscola(Escola escola) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmação'),
        content: Text('Deseja excluir esta escola?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _escolaCollection.doc(escola.id).delete();
              Navigator.pop(context);
            },
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
