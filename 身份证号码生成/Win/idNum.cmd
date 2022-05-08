
:: 注释结尾加空格，解决 '*' is not recognized as an internal or external command, operable program or batch file. 

:: 取消所有命令的回显 
@echo off

:: 声明采用UTF-8编码，解决中文乱码问题 
chcp 65001
CLS

setlocal enabledelayedexpansion

echo.
echo 作者：苏俊海 
echo 网址：https://e-e.fun    https://github.com/e-su 
echo 日期：2022年5月1日 
echo 声明：此程序仅供测试，不可用于非法活动 
echo.
echo 身份证号码示例 
echo 52   46   64  19950714    729        X 
echo 省份 地市 区县  生日  顺序码(性别) 校验码 
echo.
echo 使用说明 
echo 1.直接按回车键生成 
echo 2.可以输入省市，如 5246 再按回车键生成 
echo 3.可以指定生日(8位)，前面用 * 占位，如 ******19950714  再按回车键生成 
echo.
echo 不校验输入有效 
echo 不保证输出有效 
echo 请按回车键生成 
echo.
goto :mainLoop


:: 省份 
:getProvinceCode
set provinceCodeArr=11 12 13 14 15 21 22 23 31 32 33 34 35 36 37 41 42 43 44 45 46 50 51 52 53 54 61 62 63 64 65 71 81 82
set min=1
set max=34
set /a randomI=%random%%%(max+1-min)+min
set i=0
for %%a in (%provinceCodeArr%) do (
    set /a i+=1
    if !i! == !randomI! (
        set provinceCode=%%a
    )
)
goto :eof


:: 地市 
:getCityCode
set cityCodeArr=01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 90
set min=1
set max=71
set /a randomI=%random%%%(max+1-min)+min
set i=0
for %%a in (%cityCodeArr%) do (
    set /a i+=1
    if !i! == !randomI! (
        set cityCode=%%a
    )
)
goto :eof


:: 区县 
:getTownCode
set min=1
set max=99
set /a randomI=%random%%%(max+1-min)+min
set townCode=!randomI!
if !townCode! lss 10 (
    set townCode=0!townCode!
)
goto :eof


:: 生日 
:getDateCode
:: %date% 可能是 "周二 2022/04/26" 或 "2022/04/26 周二" 
for /f "tokens=1 delims= " %%a in ("%date%") do (
    set str1=%%a
)
for /f "tokens=2 delims= " %%a in ("%date%") do (
    set str2=%%a
)
call :countStr !str1! count1
call :countStr !str2! count2
if !count1! gtr !count2! (
    set dateStr=!str1!
) else (
    set dateStr=!str2!
)
:: 计算指定天数之前的日期 
:: 20岁到60岁 
set min=7300
set max=21900
set /a daysAgo=%random%%%(max+1-min)+min
call :dateToDays %dateStr:~0,4% %dateStr:~5,2% %dateStr:~8,2% days
set /a days-=%daysAgo%
call :daysToDate %days% yyyy mm dd
set dateCode=%yyyy%%mm%%dd%
goto :eof


:: 计算字符串长度 
:countStr %str% count
set str=%1
set count=0
:loop_countStr
if not "!str:~%count%,1!" == "" (
    set /a count+=1
    goto :loop_countStr
)
set %2=!count!
goto :eof


:: 年月日转天数 
:dateToDays %yyyy% %mm% %dd% days
setlocal enableextensions
set yyyy=%1&set mm=%2&set dd=%3
set /a dd=100%dd%%%100,mm=100%mm%%%100
set /a z=14-mm,z/=12,y=yyyy+4800-z,m=mm+12*z-3,j=153*m+2
set /a j=j/5+dd+y*365+y/4-y/100+y/400-2472633
endlocal&set %4=%j%
goto :eof


:: 天数转年月日 
:daysToDate %days% yyyy mm dd
setlocal enableextensions
set /a a=%1+2472632,b=4*a+3,b/=146097,c=-b*146097,c/=4,c+=a
set /a d=4*c+3,d/=1461,e=-1461*d,e/=4,e+=c,m=5*e+2,m/=153,dd=153*m+2,dd/=5
set /a dd=-dd+e+1,mm=-m/10,mm*=12,mm+=m+3,yyyy=b*100+d-4800+m/10
(if %mm% lss 10 set mm=0%mm%)&(if %dd% lss 10 set dd=0%dd%)
endlocal&set %2=%yyyy%&set %3=%mm%&set %4=%dd%
goto :eof


:: 顺序码(性别) 
:getSnCode
set min=1
set max=999
set /a snCode=%random%%%(max+1-min)+min
if !snCode! lss 10 (
    set snCode=00!snCode!
) else if !snCode! lss 100 (
    set snCode=0!snCode!
)
goto :eof


:: 计算校验码并得出身份证号码 
:getCheckCode
set code17=!provinceCode!!cityCode!!townCode!!dateCode!!snCode!
set sumOfProducts=0
for /l %%i in (0,1,16) do (
    set codeI=!code17:~%%i,1!
    :: 公式 wi=(2^(i-1))(mod 11) 计算加权因子，i从18开始 
    set /a y=18-%%i-1
    call :pow 2 !y! z
    set /a weightingFactorI=!z!%%11
    :: 公式 ci×wi 计算乘积 
    set /a product=!codeI!*!weightingFactorI!
    :: 公式 ∑ci×wi 计算各乘积的和 
    set /a sumOfProducts+=!product!
)
:: 公式 ∑ci×wi(mod 11) 取余 
set /a residual=!sumOfProducts!%%11

:: 校验码 
set c1=0
for /l %%i in (0,1,10) do (
    :: 根据 ∑ci×wi(mod 11)+c1≡1(mod 11) 得出 c1 的值 
    set /a p=!residual!+%%i
    set /a m=!p!%%11
    if !m!==1 set c1=%%i
)
if !c1!==10 set c1=X
set idNum=!code17!!c1!
goto :eof


:: z=x^y
:pow %x% %y% z
setlocal
set result=1
set x=%1
set y=%2
:loop_pow
if "%y%"=="0" endlocal & set %3=%result% & goto :eof
set /a result*=%x%
set /a y-=1
goto :loop_pow


:parseInput
set /p inputNum=
echo !inputNum! | findstr "[0-9]" > nul && (
    echo !inputNum! | findstr "^[1-9][0-9]" > nul && set provinceCode=!inputNum:~0,2!
    echo !inputNum! | findstr "^..[0-9][0-9]" > nul && set cityCode=!inputNum:~2,2!
    echo !inputNum! | findstr "^....[0-9][0-9]" > nul && set townCode=!inputNum:~4,2!
    echo !inputNum! | findstr "^......[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" > nul && set dateCode=!inputNum:~6,8!
    echo !inputNum! | findstr "^..............[0-9][0-9][0-9]" > nul && set snCode=!inputNum:~14,3!
)
set inputNum=
goto :eof


:mainLoop

set provinceCode=00
set cityCode=00
set townCode=00
set dateCode=00000000
set snCode=000
set idNum=000000000000000000

call :parseInput
if !provinceCode!==00 call :getProvinceCode
if !cityCode!==00 call :getCityCode
if !townCode!==00 call :getTownCode
if !dateCode!==00000000 call :getDateCode
if !snCode!==000 call :getSnCode
call :getCheckCode

echo !idNum!
echo.

goto :mainLoop
