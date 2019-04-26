
import 'package:test/test.dart';

import 'package:chess_with_friends/Square.dart';
import 'package:chess_with_friends/Move.dart';
import 'package:chess_with_friends/Game.dart';
import 'package:chess_with_friends/PayloadGame.dart';
import 'package:chess_with_friends/History.dart';


void main() {


  test('test stalemate', () {

    var game = Game.type(TypeGame.standard);
    var notations = "g3;d5;Bg2;Nf6;h3;c5;b3;Nc6;Bb2;e5;a3;Bd6;d3;Be6;Nd2;Qd7;e4;O-O-O;exd5;Nxd5;Ne4;Be7;Ne2;f5;N4c3;Nxc3;Bxc3;f4;Qd2;Nd4;gxf4;Bh4;O-O-O;Qc7;fxe5;Qxe5;f4;Qxe2;Qxe2;Nxe2+;Kb2;Nxc3;Kxc3;Bd5;Bxd5;Rxd5;Kc4;Bf6;Kxd5;Rd8+;Kc4;a6;a4;Rd4+;Kxc5;Kc7;c4;b6+;Kb4;Rxf4;Rhf1;Rd4;Rfe1;Kc6;Re4;a5+;Ka3;Rd7;Re6+;Kb7;Re4;Be7+;Ka2;Bb4;d4;Rf7;Re2;Rf3;d5;Kc7;d6+;Bxd6;Red2;Bc5;Rd7+;Kc6;Re1;Rxh3;Rxg7;Rh2+;Kb1;h5;Re6+;Bd6;Rgg6;Rd2;Kc1;Rd4;Kc2;Kc5;Rg5+;Kb4;Rxh5;Bf4;Re2;Ka3;Rb5;Rd6;Kb1;Rd1+;Kc2;Ra1;Rxb6;Bg5;Kd3;Ra2;Rxa2+;Kxa2;Rb5;Bd8;c5;Ka3;Kc4;Bc7;c6;Be5;Rb7;Bf4;c7;Be3;c8=Q;Bd2;Qc5+;Bb4;Rxb4;axb4;Qxb4+;Ka2;Qb5;Ka1;a5;Ka2;a6;Ka1;a7;Kb1;a8=Q;Kb2;Qe5+;Kc1;Qa2;Kd1;Qaa1+;Kc2;Qee1";

    for (String notation in notations.split(";")) {
      print("Making move $notation");
      expect(game.state, StateGame.ongoing);
      var move = game.getMoveFromNotation(notation);
      var isValid = game.makeMove(move);
      expect(isValid, true);
    }

    expect(game.state, StateGame.stalemate);
  });

  test('test Alexander Beliavsky vs Larry Mark Christiansen', () {
    
    var game = Game.type(TypeGame.standard);
    var notations = "d4;Nf6;c4;e6;g3;Bb4+;Bd2;Qe7;Bg2;Bxd2+;Qxd2;d6;Nc3;O-O;Nf3;e5;O-O;Re8;e4;Bg4;d5;Bxf3;Bxf3;Nbd7;b4;a5;a3;Ra6;Nb5;Nb6;Rac1;axb4;axb4;Qd7;Qd3;Ra4;Qb3;Rea8;Rfd1;h5;h4;g6;Rb1;Ng4;Be2;Qe7;Rbc1;c6;dxc6;bxc6;c5;dxc5;bxc5;Nd7;Nd6;Ndf6;Bc4;Nxf2;Kxf2;Ra3;Bxf7+;Kg7;Qe6;Ra2+;Kg1;R8a3;Ne8+;Kh6;Nxf6;Rxg3+;Kh1;Qxf7;Rd7;Qxf6;Qxf6;Rh2+;Kxh2";
    
    for (String notation in notations.split(";")) {
      print("Making move $notation");
      expect(game.state, StateGame.ongoing);
      var move = game.getMoveFromNotation(notation);
      var isValid = game.makeMove(move);
      expect(isValid, true);
    }

    expect(game.state, StateGame.ongoing);
  });


  test('test Byrne vs. Fischer, New York 1956', () {

    var game = Game.type(TypeGame.standard);
    var notations = "Nf3;Nf6;c4;g6;Nc3;Bg7;d4;O-O;Bf4;d5;Qb3;dxc4;Qxc4;c6;e4;Nbd7;Rd1;Nb6;Qc5;Bg4;Bg5;Na4;Qa3;Nxc3;bxc3;Nxe4;Bxe7;Qb6;Bc4;Nxc3;Bc5;Rfe8+;Kf1;Be6;Bxb6;Bxc4+;Kg1;Ne2+;Kf1;Nxd4+;Kg1;Ne2+;Kf1;Nc3+;Kg1;axb6;Qb4;Ra4;Qxb6;Nxd1;h3;Rxa2;Kh2;Nxf2;Re1;Rxe1;Qd8+;Bf8;Nxe1;Bd5;Nf3;Ne4;Qb8;b5;h4;h5;Ne5;Kg7;Kg1;Bc5+;Kf1;Ng3+;Ke1;Bb4+;Kd1;Bb3+;Kc1;Ne2+;Kb1;Nc3+;Kc1;Rc2#";

    for (String notation in notations.split(";")) {
      print("Making move $notation");
      expect(game.state, StateGame.ongoing);
      var move = game.getMoveFromNotation(notation);
      var isValid = game.makeMove(move);
      expect(isValid, true);
    }

    expect(game.state, StateGame.checkmate);
  });


  test('test Kasparov vs. Topalov, Linares 1999', () async {

    var game = Game.type(TypeGame.standard);
    var notations = "e4;d6;d4;Nf6;Nc3;g6;Be3;Bg7;Qd2;c6;f3;b5;Nge2;Nbd7;Bh6;Bxh6;Qxh6;Bb7;a3;e5;O-O-O;Qe7;Kb1;a6;Nc1;O-O-O;Nb3;exd4;Rxd4;c5;Rd1;Nb6;g3;Kb8;Na5;Ba8;Bh3;d5;Qf4;Ka7;Rhe1;d4;Nd5;Nbxd5;exd5;Qd6;Rxd4;cxd4;Re7;Kb6;Qxd4;Kxa5;b4;Ka4;Qc3;Qxd5;Ra7;Bb7;Rxb7;Qc4;Qxf6;Kxa3;Qxa6;Kxb4;c3;Kxc3;Qa1;Kd2;Qb2;Kd1;Bf1;Rd2;Rd7;Rxd7;Bxc4;bxc4;Qxh8;Rd3;Qa8;c3;Qa4;Ke1;f4;f5;Kc1;Rd2;Qa7";

    for (String notation in notations.split(";")) {
      print("Making move $notation");
      expect(game.state, StateGame.ongoing);
      var move = game.getMoveFromNotation(notation);
      var isValid = game.makeMove(move);
      expect(isValid, true);
    }

    expect(game.state, StateGame.ongoing);
  });


  test('converting payload game move end', () {

    var move = Move(Square(0, 0), Square(1, 1));
    var action1 = PayloadGame.endMove(move, 1.11111111111111);
    var bytes1 = action1.toBytes();
    var action2 = PayloadGame.fromBytes(bytes1);

    expect(action1.type == action2.type, true);
    expect(action1.move == action2.move, true);
    expect((action1.timestampEnd - action2.timestampEnd).abs() < 0.00001, true);
    expect(action1.timestampStart == action2.timestampStart, true);
    expect(action1.control == action2.control, true);
  });


  test('test converting payload game identifier', () async {

    var action1 = PayloadGame.setIdDevice("hello world");
    var bytes1 = action1.toBytes();
    var action2 = PayloadGame.fromBytes(bytes1);

    expect(action1.type == action2.type, true);
    expect(action1.idDevice == action2.idDevice, true);
  });

  test('test encode decode GameHistory', () async {

    var idDevice = "id-device";
    var nameLight = "light";
    var nameDark = "dark";
    var moves = [MoveGameHistory("d4", 100)];
    var gameHistory = GameHistory(idDevice: idDevice, nameLight: nameLight, nameDark: nameDark, isLightWinner: true, result: ResultGameHistory.checkmate, moves: moves);
    History.saveGame(gameHistory);
    var games = await History.getGames();
    var gameToMatch = games.firstWhere((game) => game.idDevice == idDevice);

    expect(gameHistory.idDevice == gameToMatch.idDevice, true);
    expect(gameHistory.nameLight == gameToMatch.nameLight, true);
    expect(gameHistory.nameDark == gameToMatch.nameDark, true);
    expect(gameHistory.isLightWinner == gameToMatch.isLightWinner, true);
    expect(gameHistory.result == gameToMatch.result, true);
    expect(gameHistory.moves.first.notation == gameToMatch.moves.first.notation, true);
    expect(gameHistory.moves.first.time == gameToMatch.moves.first.time, true);

  });
}