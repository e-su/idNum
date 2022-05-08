
#!/bin/zsh

echo
echo 作者：苏俊海
echo 日期：2022年5月1日
echo "网址：https://e-e.fun    https://github.com/e-su"
echo 声明：此程序仅供测试，不可用于非法活动
echo
echo 身份证号码示例
echo "52   46   64  19950714    729        X"
echo "省份 地市 区县  生日  顺序码(性别) 校验码"
echo
echo 使用说明
echo 1.直接按回车键生成
echo 2.可以输入省市，如 5246 再按回车键生成
echo "3.可以指定生日(8位)，前面用 * 占位，如 ******19950714  再按回车键生成"
echo
echo 不校验输入有效
echo 不保证输出有效
echo 请按回车键生成
echo


# 省份
getProvinceCode() {
    provinceCodeArr=(
    11 12 13 14 15
    21 22 23
    31 32 33 34 35 36 37
    41 42 43 44 45 46
    50 51 52 53 54
    61 62 63 64 65
    71
    81 82)
    min=0
    max=`expr ${#provinceCodeArr[*]} - 1`
    index=`expr $RANDOM % \( $max + 1 - $min \) + $min`
    provinceCode=${provinceCodeArr[index]}
}


# 地市
getCityCode() {
    cityCodeArr=($(seq 1 1 70) 90)
    min=0
    max=`expr ${#cityCodeArr[*]} - 1`
    index=`expr $RANDOM % \( $max + 1 - $min \) + $min`
    code=${cityCodeArr[index]}
    
    if [ $code -lt 10 ]
    then
    code="0$code"
    fi
    
    cityCode=$code
}


# 区县
getTownCode() {
    min=1
    max=99
    code=`expr $RANDOM % \( $max + 1 - $min \) + $min`
    
    if [ $code -lt 10 ]
    then
    code="0$code"
    fi
    
    townCode=$code
}


# 生日
getDateCode() {
    # 20岁到60岁
    min=7300
    max=21900
    dateCode=$(date -v -`expr $RANDOM % \( $max + 1 - $min \) + $min`d +%Y%m%d)
}


# 顺序码(性别)
getSnCode() {
    min=1
    max=999
    code=`expr $RANDOM % \( $max + 1 - $min \) + $min`
    
    if [ $code -lt 10 ]
    then
    code="00$code"
    elif [ $code -lt 100 ]
    then
    code="0$code"
    fi
    
    snCode=$code
}


# 计算校验码并得出身份证号码
getCheckCode() {
    code17=$provinceCode$cityCode$townCode$dateCode$snCode
    
    sumOfProducts=0
    for i in {0..16}
    do
    codeI=${code17: i: 1}
    # 公式 wi=(2^(i-1))(mod 11) 计算加权因子，i从18开始
    weightingFactorI=$[2**(18-$i-1)%11]
    # 公式 ci×wi 计算乘积
    product=$[codeI*weightingFactorI]
    # 公式 ∑ci×wi 计算各乘积的和
    sumOfProducts=$[sumOfProducts+product]
    done
    # 公式 ∑ci×wi(mod 11) 取余
    residual=$[sumOfProducts%11]
    
    # 校验码
    c1=0
    for i in {0..10}
    do
    # 根据 ∑ci×wi(mod 11)+c1≡1(mod 11) 得出 c1 的值
    if [ $[(residual+i)%11] -eq 1 ]
    then
    c1=$i
    fi
    done
    
    if [ $c1 -eq 10 ]
    then
    c1=X
    fi
    
    idNum=$code17$c1
}


parseInput() {
    read -a inputNum
    [ $(echo $inputNum | grep "[0-9]") ] && {
        [ $(echo $inputNum | grep "^[1-9][0-9]") ] && provinceCode=${inputNum: 0: 2}
        [ $(echo $inputNum | grep "^..[0-9][0-9]") ] && cityCode=${inputNum: 2: 2}
        [ $(echo $inputNum | grep "^....[0-9][0-9]") ] && townCode=${inputNum: 4: 2}
        [ $(echo $inputNum | grep "^......[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]") ] && dateCode=${inputNum: 6: 8}
        [ $(echo $inputNum | grep "^..............[0-9][0-9][0-9]") ] && snCode=${inputNum: 14: 3}
    }
}


while :
do

provinceCode=00
cityCode=00
townCode=00
dateCode=00000000
snCode=000
idNum=000000000000000000

parseInput
[ $provinceCode -eq 00 ] && getProvinceCode
[ $cityCode -eq 00 ] && getCityCode
[ $townCode -eq 00 ] && getTownCode
[ $dateCode -eq 00000000 ] && getDateCode
[ $snCode -eq 000 ] && getSnCode
getCheckCode

echo $idNum
echo

done
