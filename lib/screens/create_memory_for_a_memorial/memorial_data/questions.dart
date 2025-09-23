import 'package:flutter_frontend/models/question_category.dart';

final List<QuestionCategory> questionsCategories = [
  QuestionCategory(
    name: "INFANCIA Y JUVENTUD",
    questions: [
      "¿Cuál es tu recuerdo favorito de tu infancia?",
      "¿Qué travesura hiciste que más recuerdas?",
      "¿Qué sueño tenías cuando eras niño?",
    ],
  ),
  QuestionCategory(
    name: "FAMILIA Y TRADICIONES",
    questions: [
      "¿Qué tradición familiar recuerdas con más cariño?",
      "¿Quién fue la persona que más influyó en tu niñez?",
      "¿Cómo celebraban las fiestas en tu familia?",
    ],
  ),
  QuestionCategory(
    name: "AMOR Y RELACIONES",
    questions: [
      "¿Cómo conociste a una persona especial en tu vida?",
      "¿Qué es lo más importante que aprendiste sobre el amor?",
      "¿Qué consejo darías para mantener una relación duradera?",
    ],
  ),
  QuestionCategory(
    name: "SABIDURÍA Y LEGADO",
    questions: [
      "¿Qué enseñanza de vida consideras más valiosa?",
      "¿Qué consejo te hubiera gustado recibir de joven?",
      "¿Qué legado quisieras dejar a las siguientes generaciones?",
    ],
  ),
  QuestionCategory(
    name: "PERSONALIDAD Y MANÍAS",
    questions: [
      "¿Cuál dirías que es tu mayor virtud?",
      "¿Tienes alguna manía o hábito curioso?",
      "¿Qué te hace sentir auténticamente feliz?",
    ],
  ),
  QuestionCategory(
    name: "CREAR MI PROPIA PREGUNTA",
    questions: [
      "Escribe aquí una pregunta personalizada",
      "Escribe otra pregunta personalizada",
      "Agrega una tercera pregunta personalizada",
    ],
  ),
];
