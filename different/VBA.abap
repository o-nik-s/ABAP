Function KolichestvoIzmereniy(myArr As Variant) As Long
On Error GoTo Instr
  Dim i As Long, m As Long
  i = 0
    Do While True
      i = i + 1
      m = UBound(myArr, i)
    Loop
Instr:
  KolichestvoIzmereniy = i - 1
End Function

Sub InitializeMatrix(Var1, Var2, Var3, Var4)
	On Error GoTo ОбработкаОшибок
	. . .
	Exit Sub
ОбработкаОшибок:
	. . .
	Resume Next
End Sub

Sub OnErrorStatementDemo()
	On Error GoTo ErrorHandler			' Включаем программу обработки 
						' ошибок.
	Open "TESTFILE" For Output As #1		' Открываем файл.
	Kill "TESTFILE"				' Попытка удалить открытый 
						' файл.
	On Error Goto 0				' Отключаем перехват ошибок.
	On Error Resume Next			' Откладываем перехват ошибок.
	ObjectRef = GetObject("MyWord.Basic")	' Запускаем несуществующий 
						' объект, а затем проверяем 
						' ошибку механизма управления 
						' программируемыми объектами.
	If Err.Number = 440 Or Err.Number = 432 Then
	' Выводим сообщение для пользователя и очищаем объект Err.
		Msg = "Ошибка при попытке открыть программируемый объект!"
		MsgBox Msg, , "Проверка отложенной ошибки"
		Err.Clear			' Очищаем поля объекта Err.
	End If	
Exit Sub					' Выходим из процедуры, чтобы не попасть в обработчик.
ErrorHandler:					' Обработчик ошибок.
	Select Case Err.Number			' Определяем код ошибки.
		Case 55						' "Ошибка "Файл уже открыт".
			Close #1		' Закрываем открытый файл.
		Case Else
			' Здесь размещаются инструкции для обработки других ошибок... 
	End Select
	Resume					' Возобновляем выполнение со строки, вызвавшей ошибку.
End Sub