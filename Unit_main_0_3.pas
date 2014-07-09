unit Unit_main_0_3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Math;

type
  TForm1 = class(TForm)
    Pole: TShape;
    paddle: TShape;
    Intpaddle: TShape;
    ball: TShape;
    Timer1: TTimer;
    playerScoreLabel: TLabel;
    computerScoreLabel: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure PoleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure PoleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
  TRecBrik = record
   BrikName : shortstring;
   x, y, w, h, number : integer;
   visible : boolean;
  end;

var
  Form1: TForm1;
  passedPaddle : boolean = false;  // пролетел ли мячик  пад?
  GameOverBool : boolean = false;  // Игра окончена?
  LevelCreateBool : boolean = true; //  условие построения уровня
  LevelDoneBool : Boolean = false;  // уровень пройден?
  BallFlight : Boolean = false;     // мячик в игре?
  numBalls : integer;              // кол-во оставшихся шариков
  computerScore : integer = 0;      // счёт компа
  playerScore : integer = 0;        // счёт игрока

  dx : real = 1.0; // скорость по х
  dy : real = 1.0; // скорость по y
  ballx, bally : integer;  // координаты мячика
  rightWall, leftWall, topWall, bottomWall : integer; // координты стенок

  levelnumber : integer; // номер уровня
  levelname : shortstring;  // имя уровня для чтения файла
  RecBrik : TRecBrik;    // запись бриков

const

  paddleHeight=80;
  paddleWidth=2;    // характеристики пада

  poleHeight=450;     // характеристики поля
  poleWidth=450;
  poleTop = 20;
  poleLeft = 20;

  ballRadius = 10;   // радиус мяча
  NumConst = 6;      // число мячиков

  moveAmount = 5; // скорость реакции пада компьютера

implementation

{$R *.dfm}

procedure LevelStart;  // процедура запуска уровня
 begin
   // булы устанавливаем на значения начала уровня
  BallFlight := false;    // мячик сидит на паде
  passedPaddle := false;   // не пролетел пад
  GameOverBool := false;   // игра не закончена

  form1.timer1.Enabled := true; // включаем таймер
 end;

procedure LevelDone;   // проц. прохождения уровня
  var f: file of TRecBrik;
 begin
  assignfile(f,levelname); // связываем файл уровня
  erase(f);                // удаляем tmp файл
  LevelCreateBool := true;   //  надо создать новый уровень
  LevelDoneBool := false;    // уровень не пройден
  levelnumber := levelnumber + 1; // новый номер
  LevelStart;                  // запускаем уровень
 end;

procedure GameWin;   // проц. окончания игры
// var f: file of TRecBrik;
 begin
 // LevelStart;
  form1.Timer1.Enabled := false;  // выкл. таймер
  case MessageDlg('Вы прошли игру!!! Мы вас ПОЗДРАВЛЯЕМ!!! Вы хотите начать заного?'
    , mtConfirmation, [mbYes, mbNo], 0) of
    idYes :              // вызываем сообщение
      begin               // если ДА то запускаем всё завново
       numBalls := NumConst;   // воостанавливаем мячики
       LevelCreateBool := true;  // надо создать уровень
       levelnumber := 1;
       levelname := 'level1.dat'; // по любому первый уровень

       playerScore:=0;    // счёт в нули
       computerScore:=0;
       form1.playerScoreLabel.Caption:='0';
       form1.computerScoreLabel.Caption:='0';

       form1.Timer1.Enabled := true; // запускаем таймер
      end;
    idNo:      // выходим
      begin
     //  assignfile(f,levelname);
     //  erase(f);
       halt;
      end;
  end;
 end;
 
procedure LevelCreate;  // процедура построения уровня, бриков.
 var
  f,ftmp: file of TRecBrik;
  BrikBitmap : TBitmap; // класс файлов типа bmp для рисования брика
 begin
// копирование файла в tmp
 if LevelCreateBool then
  begin
   levelname:='level' + IntToStr(levelnumber) + '.dat';
   assignfile(f,levelname);  // связывание
   {$I-} reset(f); {$I+}
   if IOResult<>0 then    // если файл не существует значит игра пройдена
                    begin
                      gamewin;
                      exit;
                    end;
   levelname:='level' + IntToStr(levelnumber) + '.tmp'; // новое имя tmp файла
   assignfile(ftmp,levelname); rewrite(ftmp); // создаём
   while not eof(f) do  // копируем
    begin
     read(f,RecBrik);
     write(ftmp,RecBrik);
    end;
   CloseFile(f); CloseFile(ftmp); LevelCreateBool := false; // уровень создан
  end;
// создание BrikGraphic
 BrikBitmap := TBitmap.Create; // созадём temp класс картинки брика и грузим его в пямять
  try
    with BrikBitmap do
     begin
      LoadFromFile('brik_16_71.bmp'); // читаем картинку
      Transparent := false;
      assignfile(f,levelname);   // грузим файл уровня
      Reset(f);
      while not eof(f) do // создание бриков в форме
       begin
        read(f,RecBrik);
        if RecBrik.visible then   // рисуем брик если он виден
         form1.Canvas.Draw(RecBrik.x,RecBrik.y,BrikBitmap);
       end;
     end;
  finally
  BrikBitmap.Free;  // очищаем пямять
 end;
 closefile(f);
end;

procedure TForm1.FormCreate(Sender: TObject);  // проц выполняющаяся при 1-ом запуске игры
begin
   pole.Height := poleHeight;  // устанавливаем значения из констант
   pole.Width := poleWidth;
   pole.Top := poleTop;
   pole.left := poleLeft;

   paddle.Height:=paddleHeight;
   paddle.Width:=paddleWidth;
   Intpaddle.Height:=paddleHeight;
   Intpaddle.Width:=paddleWidth;

   Cursor:=crNone;      // убираем курсор

   timer1.Interval:=1;    // интервал , вкл. таймер
   timer1.Enabled:=true;

   rightWall:=poleWidth+poleLeft;  // расчитываем стены
   leftWall:=poleLeft;
   topWall:=poleTop;
   bottomWall:=poleTop+poleHeight;

   levelnumber:=1;       // номер уровня
   numBalls := numConst;     // количество мячиков

   LevelStart;          // запускаем уровень

   form1.Canvas.Pen.Width   := 1;   // цвета для стирания бриков
   form1.Canvas.Pen.Color   := clBtnFace;
   form1.Canvas.Brush.Color := clBtnFace;

end;

procedure TForm1.PoleMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);  // процедура двиганья пада пользователем
begin
  if (y>=poleHeight+poleTop-paddleHeight) then  // чтобы не вылезал за пределы
    paddle.Top:=poleHeight+poleTop-paddleHeight
  else if y<=poleTop then paddle.Top:=poleTop
  else paddle.Top := y;    // перемещаем по координате мышы
end;

/////////////////// проверка попадания на брик ////////////////////////////
function TryBrik(x,y,width,height : integer):boolean;
 begin
	 //проверка попадания мяча на 4-ре стороны
  result:=false; // не попал
 	if (ballx + ballRadius >= x ) then
   if (ballx - ballRadius <= x + width) then
 		if  (bally + ballRadius >= y ) then
 		 if (bally - ballRadius <= y + height) then
      result:=true; // если пересёк координату то попал
 end;
////////////////// function brick(x,y : integer):boolean; /////////////////

procedure DestroyBrik; // процедура уничтожения брика
 var f: file of TRecBrik;
     n, k : integer;
 begin
  assignfile(f,levelname);   // грузим файл уровня
  Reset(f);
  k:=filesize(f); // общее кол-во бриков, высчитываем по записям
  n:=0; // количество уничтоженных бриков
  while not eof(f) do   // пока в файле есть записи
   begin
    read(f,RecBrik);  // читаем
    if RecBrik.visible then // если брик виден
     begin
      if TryBrik(RecBrik.x,RecBrik.y,RecBrik.w,RecBrik.h) then
       begin    // если на него попал мячик то
        form1.Canvas.Rectangle(RecBrik.x,RecBrik.y,  // закрашиваем под цвет формы
          RecBrik.x+RecBrik.w,RecBrik.y+RecBrik.h );
        RecBrik.visible := false;// ставим в невидимые
        seek(f,RecBrik.number-1); // возвращаемся к прочитанно записи
        write(f,RecBrik);     // пишем изменённую
       { if InRange(ballx, RecBrik.x - ballRadius,
        RecBrik.y + RecBrik.w + ballRadius) then  }
          dx:=dx*(-1.0); // меняем скорость на противоположную
       { else dy:=dy*(-1.0);}
       end; ////////////// TryBrik(x,y,RecBrik.w,RecBrik.h)/////
     end  // если брик не виден то увеличиваем кол-во невидимых бриков
    else n:=n+1;
   end;  //////////////////// RecBrik.visible////////////////////////
  if k = n then LevelDoneBool := true; // если все брики невидимы то уровень пройден
  closefile(f);
 end;  // DestroyBrik;

 procedure MoveBall; // процедура перемещения мячика
 var overshoot, x, y, tmp : integer;
 begin     // overshoot - переменная , определяет на сколько мячик улетел за стенку при отражении

  x := ballx; // берём координаты мячика из глобальных
  y := bally;

  x:=x+round(dx); // увеличиваем их на скорость
  y:=y+round(dy);

  if not BallFlight then   // "общее" условие полёта мяча
   begin      // если мячик не летит значит он должен быть на паде и двигаться вместе с ним
    x:=round(form1.paddle.Left + paddleWidth + ballRadius);
    y:=round(form1.paddle.Top + paddleHeight/2.0);
    dx:=0.0; // скорость равна 0
    dy:=0.0;
   end
  else  // если он летит значит проверки!!!
   begin
    if round(dy) = 0 then dy:=1.0; // чтобы он не летел перпендикулярно
    if round(dx) = 0 then dx:=1.0;
    if dy > 10 then dy:=sign(dy)*10.0; // ограничение скорости
    if dx > 5 then dx:=sign(dx)*5.0;
/////////////////// отражение от нижней стенки ////////////////////////////
 if (y + ballRadius >= bottomWall) then
  begin
   overshoot := (y+ballRadius) - bottomWall;
   y := y - overShoot*2;
   dy := dy*(-1.05);
  end;

/////////////////// отражение от верхней стенки //////////////////////
  if (y - ballRadius <= topWall) then
   begin
    overshoot := topWall - (y - ballRadius);
    y :=y + overShoot*2;
    dy := dy*(-1.05);
   end;

/////////////////// отражение мяча от левого пада //////////////////////
  if ((x - ballRadius < leftWall + paddleWidth)and not passedPaddle) then
   begin
    if {(y  > form1.paddle.Top)and (y < form1.paddle.Top + paddleHeight)}
     InRange(y,form1.paddle.Top,form1.paddle.Top + paddleHeight) then
     begin
      overshoot :=  leftWall + paddleWidth - ( x - ballRadius );
      x  :=x + overShoot*2;
      dx :=dx*(-1.0);
      if (y < form1.paddle.Top + round(paddleHeight/4) )
           or           // условие ускорения при попадания на край пада
         (y > form1.paddle.Top + round(paddleHeight*3/4) )
       then
         begin
           tmp := sign(dy)*abs(round((y - ( form1.paddle.Top + paddleHeight/2 ) )/8));
           if abs(tmp) > abs(dy) then dy:=tmp; // проверяме новая скорость больши ли текущей
         end;       // для того чтобы не происходило торможения мяча при попадании в меньший угол скорости
      dx := dx*1.05;  // увеличиваем скорость
      dy := dy*1.05;
     end
    else passedPaddle := true;  // если не попал значит мячик пролетел
   end;

/////////////////// отражение мяча от правого пада //////////////////////
  if ((x + ballRadius > rightWall - paddleWidth)and not passedPaddle) then
   begin
    if {(y  > form1.Intpaddle.Top) and (y < form1.Intpaddle.Top + paddleHeight)}
       InRange(y,form1.Intpaddle.Top,form1.Intpaddle.Top + paddleHeight) then
     begin
      overshoot :=  (x + ballRadius) - (rightWall - paddleWidth);
      x  :=x - overShoot*2;
      dx :=dx*(-1.0);
       if (y < form1.Intpaddle.Top + round(paddleHeight/4) )
           or
         (y > form1.Intpaddle.Top + round(paddleHeight*3/4) )
       then
         begin
           tmp := sign(dy)*abs(round((y - ( form1.intpaddle.Top + paddleHeight/2 ) )/8));
           if abs(tmp) > abs(dy) then dy:=tmp; // проверяме новая скорость больши ли текущей
         end; // для того чтобы не происходило торможения мяча при попадании в меньший угол скорости
      dx :=dx*1.05;  // увеличиваем скорость
      dy :=dy*1.05;
     end
    else passedPaddle := true; // если не попал значит мячик пролетел
   end;

/////////////////// попал ли мяч на левую стену ? //////////////////
  if ((x-ballRadius < leftWall + paddleWidth ) and passedPaddle) then
   begin
    computerScore:=computerScore+1;  // увеличиваем счёт
    form1.computerScoreLabel.Caption :=IntToStr(computerScore);
    if (numBalls = 0) then GameOverBool:=true //game over
    else                  // если кол-во мячей 0 то игра кончена
     begin
      numBalls:=numBalls-1;  // уменьшаем кол-во мячей
      LevelStart; //start level
      exit;
     end;  //if (numBalls = 0)
   end;  // if ((x-ballRadius < leftWall + paddleWidth ) and passedPaddle)

/////////////////// попал ли мяч на правую стену ? //////////////////
 if ((x+ballRadius > rightWall - paddleWidth) and passedPaddle) then
  begin
   playerScore:=playerScore+1 ;  // увеличиваем счёт
   form1.playerScoreLabel.Caption:=IntToStr(playerScore);
   if (numBalls = 0) then
   GameOverBool:=true //game over
   else         // если кол-во мячей 0 то игра кончена
    begin
     numBalls:=numBalls-1;     // уменьшаем кол-во мячей
     LevelStart; //start level
     exit;
    end;  // if (numBalls = 0)
  end; //if ((x+ballRadius > rightWall - paddleWidth) and passedPaddle)

  DestroyBrik; // запускаем проверку бриков
 end;

  ballx := x;  // возвращаем новые координаты
  bally := y;

  form1.ball.Top := bally-ballradius; // устанавливаем новое положение
  form1.ball.Left := ballx-ballradius; // мяча
 end;


procedure GameOver; // конец игры
 var WinText : string; // текс для победителя
     f: file of TRecBrik;
 begin
   if playerScore > computerScore then WinText:='Вы Выиграли.'
   else WinText:='Вы Проиграли.';  // кто выграл?

   LevelStart;    // запускаем уровень
   form1.Timer1.Enabled:=false;  // выключаем таймер

   numBalls := NumConst;  // мячики
   LevelCreateBool := true; // создание уровня
///////////// чего мы делаем?? ////////////
   case MessageDlg(WinText + ' Вы хотите начать заного?'
   , mtConfirmation, [mbYes, mbNo], 0) of
    idYes :  // если Да
      begin
       playerScore:=0;   // всё в 0
       computerScore:=0;
       form1.playerScoreLabel.Caption:='0';
       form1.computerScoreLabel.Caption:='0';

       form1.Timer1.Enabled:=true; // запускаем таймер
      end;
    idNo:    // нет значит
      begin
       assignfile(f,levelname); // удаляем tmp файл
       erase(f);
       halt;
      end;
   end; //case MessageDlg()
 end;

procedure MoveIntPaddle; // процедура автономного управления комп. пада
 var y : integer;
 begin
 y := bally;   // берём координаты
 if (dx > 0) then // если мячик летит к компу то
  begin
  // двигаем вверх
   if (y < form1.intPaddle.top-moveAmount) then
    form1.intPaddle.top :=form1.intPaddle.top - moveAmount
// двигаем вниз
   else if (y > form1.intPaddle.top+moveAmount) then
    form1.intPaddle.top :=form1.intPaddle.top + moveAmount;
   if (form1.intPaddle.top + paddleHeight >= poleHeight+poleTop) then
    form1.intpaddle.Top := poleHeight+poleTop-paddleHeight
  end;
 end;


procedure TForm1.Timer1Timer(Sender: TObject); // таймер
begin
 levelcreate;    // рисуем уровень
 MoveBall;       // двигаем мячик
 MoveIntPaddle;   // двигаем комп. пад
 if GameOverBool then gameover;// игра окончена?
 if LevelDoneBool then leveldone;  // уровень пройден?
 // для debug'a
  {form1.Label3.Caption:= IntToStr(round(dx))+'___' +IntToStr(round(dy));  }
end;

procedure TForm1.PoleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);// если нажата кнопка запуск
begin
 if not BallFlight then // если мячик не летит
  begin
   BallFlight:=true;  // запускаем его
   dx:=1.0;       //  скорость по х
   if form1.paddle.Top + paddleHeight/2 > PoleHeight/2 + poletop then dy:=1.0
   else dy:=-1.0; // скорость по y , если пад в нижней половине , мячик летит вниз
  end;           // иначе вверх
end;

end.
