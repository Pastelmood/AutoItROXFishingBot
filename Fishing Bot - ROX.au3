#Region Include
; เพื่อเรียกใช้ฟังก์ชัน _SendMessage
#include <SendMessage.au3>

; เพื่อเรียกใช้ฟังก์ชัน _WinAPI_MakeLong
#include <WinAPI.au3>

; เพื่อเรียกใช้ตัวแปร ใช้ร่วมกับ _SendMessage เช่น $WM_MOUSEMOVE
#include <WindowsConstants.au3>
#EndRegion

#Region Operation Mode
; Operation mode เซตเป็น 2 คือ Client mode
; พิกัดจะวัดตามหน้าต่างของโปรแกรม ไม่ว่าโปรแกรมจะอยู่ตรงไหนของหน้าจอ
Opt("MouseCoordMode", 2)
Opt("PixelCoordMode", 2)
#EndRegion

#Region ค่า Handle ค่าสี พิกัดต่างๆ
; ค่า Handle ของโปรแกรม Nox
Global $GameHandle = WinGetHandle("NoxPlayer")

; สีปุ่มตกปลา และตำแหน่ง
; ใช้เป็น Array 5 ช่อง [สี , ค่า x, y ตำแหน่งบนซ้าย, ค่า x, y ตำแหน่งล่างขวา]
; 0xEFEFF7 คือสีขาว
Global Const $ColorHit[5] = [0xEFEFF7, 1046, 515, 1142, 604]

; สีปุ่มดึงเบ็ด และตำแหน่ง
; 0xCAF37A คือสีเขียว
Global Const $ColorFish[5] = [0xCAF37A, 1046, 515, 1142, 604]
#EndRegion

#Region Main
; ถามว่าจะตกกี่ครั้ง
$fishing = InputBox("RoX Auto Fishing", "ตกปลากี่ครั้ง")

For $i = 1 To $fishing Step 1
	; คลิกเขี้ยงเบ็ด
	colorClick($GameHandle, $ColorHit)

	; พักสัก 3 วินาที
	Sleep(3000)

	; คลิกดึงเบ็ด
	colorClick($GameHandle, $ColorFish)

	; พักสัก 3 วินาที
	Sleep(3000)
Next

; แสดงกล่องข้อความว่าเสร็จแล้ว
MsgBox($MB_OK, "RoX Auto Fishing", "ตกปลาเสร็จแล้ว")
#EndRegion

#Region ฟังก์ชัน ค้นหาตำแหน่งสี
; พารามิเตอร์ 2 ตัว คือ 1 ค่า handle และ 2 ตัวแปรอาเรย์ ที่เก็บค่าสี
Func colorSearch($handle, $color)
	; สร้างตัวแปรไว้ส่งผลลัพธ์ออก
	; ใช้เป็นอาเรย์ 3 ช่อง
	; ช่องแรกเป็น True หรือ False
	; ช่องที่ 2 กับ 3 เป็นตำแหน่งของสีที่หาเจอ คือ ค่า x กับ y
	Local $return[3]

	; นำตัวแปร $color ที่ส่งมาทางพารามิเตอร์มาแยกให้ใช้งานง่าย
	Local $colorHex = $color[0]
	Local $left = $color[1]
	Local $top = $color[2]
	Local $right = $color[3]
	Local $bottom = $color[4]

	; ใช้ฟังก์ชัน PixelSearch ค้นหาสีที่เราส่งให้ จากตัวแปร $color
	Local $colorCoordinate = PixelSearch($left, $top, $right, $bottom, $colorHex, 5, 1, $handle)

	; ตรวจสอบค่าที่ส่งมาจากฟังก์ชัน PixelSearch
	; ถ้าค้นหาสีเจอ จะส่งค่ากลับมาเป็นรูปแบบ Array เป็นพิกัดของสีที่ค้นเจอ
	If IsArray($colorCoordinate) Then
		$return[0] = True
		$return[1] = $colorCoordinate[0]
		$return[2] = $colorCoordinate[1]
	Else
		$return[0] = False
	EndIf

	; ส่งค่ากลับออกไป
	Return $return
EndFunc
#EndRegion

#Region ฟังก์ชัน คลิกพื้นหลัง คลิกแบบไม่ยึดเม้า
; ฟังก์ชันนี้ มีพารามอเตอร์ 4 ตัว
; 1 ตัวแปร handle ที่ได้จาก $Gamehandle
; 2-3 ตำแหน่ง x และ y
; 4 จำนวนที่จะคลิก ค่าเริ่มต้นตั้งให้เท่ากับ 1 (เวลาใช้จริงไม่ต้องใส่ก็ได้)
Func backgroundClick($handle, $coordinate_x, $coordinate_y, $click = 1)
	For $i = 1 To $click Step 1
		; ใส่ให้เม้าย้ายไปตรงตำแหน่งที่กำหนด
		_SendMessage($handle, $WM_MOUSEMOVE, 1, _WinAPI_MakeLong($coordinate_x, $coordinate_y))

		; ใส่ให้คลิกซ้าย
		_SendMessage($handle, $WM_LBUTTONDOWN, 1, _WinAPI_MakeLong($coordinate_x, $coordinate_y))

		; หน่วงเวลานิดนึง
		Sleep(100)

		; ปล่อยเม้าคลิกซ้าย
		_SendMessage($handle, $WM_LBUTTONUP, 0, _WinAPI_MakeLong($coordinate_x, $coordinate_y))

		; หน่วงเวลานิดนึง
		Sleep(100)
	Next
EndFunc
#EndRegion

#Region ฟังก์ชัน ค้นหาสีแล้วคลิก การผสมผสานระหว่าง ฟังก์ชัน ค้นหาตำแหน่งสีกับฟังก์ชัน คลิกพื้นหลัง คลิกแบบไม่ยึดเม้า
; พารามิเตอร์
; $handle ได้จาก $GameHandle
; $colorArray ตัวแปรที่เก็บค่าสีของวัตถุ เช่น $ColorHit
; $click จำนวนที่ต้องการคลิก ค่าเริ่มต้น 1
; $timeout โปรแกรมจะทำการค้นหาภายในระยะเวลาที่กำหนด ค่าเริ่มต้น 10 วินาที
Func colorClick($handle, $colorArray, $click = 1, $timeout = 10)
	For $i = 1 To $timeout * 5 Step 1
		; $isColorFound เก็บผลลัพธ์ของฟังก์ชัน colorSearch
		$isColorFound = colorSearch($handle, $colorArray)

		; ถ้าโปรแกรมหาสีเจอ สั่งให้คลิกลงตำแหน่งที่พบสีนั้น
		If $isColorFound[0] Then
			backgroundClick($handle, $isColorFound[1], $isColorFound[2], $click)

			; เมื่อคลิกเม้าแล้ว ให้ออกจากลูป เพื่อจบการทำงาน
			ExitLoop
		EndIf

		; หน่วงเวลา 1 วินาที
		Sleep(1000/5)

		; ในระยะเวลา 1 วินาที โปรแกรมจะทำงาน 1 ครั้ง ในกรณีที่ต้องการให้โปรแกรมทำงานถี่กว่านั้น จะทำแบบนี้
		; อยากให้ 1 วินาที ทำงาน 5 ครั้ง
		; วิธีคิด คือ ให้ตัวแปร $timeout คูณ 5 และ Sleep(1000) หาร 5
	Next
EndFunc
#EndRegion