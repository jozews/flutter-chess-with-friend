
import 'package:test/test.dart';

import 'package:chess_umbrella/Model.dart';

void main() {
  test('Kasparov vs Topalov', () {

    var game = Game.standard();
    List<Move> moves = [];

    for (Move move in moves) {
      expect(game.makeMove(move), true);
    }  
  });
}