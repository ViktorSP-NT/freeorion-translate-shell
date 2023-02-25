#!/bin/bash
c_tr () {
	c_inp="$*"
#Replacing abbreviations with more understandable texts. Add your own or delete if you want. Замена сокращений на более понятные тексты. Допишите своё или удалите, если хотите
	c_inp=`echo "$c_inp" | sed 's/ PP/ Productions Points/g'`
	c_inp=`echo "$c_inp" | sed 's/ uu/ light years/g'`
	c_inp=`echo "$c_inp" | sed 's/(uu/(light years/g'`
#Translating text with the translate-shell utility. Собственно перевод текста утилитой translate-shell
#Specify after en: the language you want to translate into. Specify the translation engines after -e. The list of available translation engines can be viewed by typing "trans -S" in the console. Укажите после en: язык на который хотите перевести. Укажите после -e переводчик. Список переводчиков можно посмотреть введя в консоли trans -S
	c_trans_ted=`trans en:ru -b -no-autocorrect -e google "$c_inp" `
	echo "$c_trans_ted"
	return
}

b_tr () {
#Processing text in < >xxx</ > tags. Обработка текста в < >xxx</ > тэгах
	b_inp="$*"
	if [[	$b_inp =~ .*\<.*\>.* ]] ; then #The line contains tags, we will cut. Строка содержит тэги, будем резать
		b_trans_ted=''
		while [[	$b_inp =~ .*\<.*\>.* ]] #While line contains tags, we will cut. Пока есть фрагменты типа < >
		do
			if [[	$b_inp =~ ^\<.* ]] ; then #This is the line that starts with c <. Это строка начавшаяся c <
				b_str1=''
				b_str0=`echo "$b_inp" | sed 's/<//'`
				if [[	$b_str0 =~ ^\/.* ]] ; then #This is the closing </ > tag. Это закрывающий тэг </ >
					add_slash="/"
					b_str0=`echo "$b_str0" | sed "s/\///"`
				else
					add_slash=""
				fi
				b_str2=`echo "$b_str0" | sed 's/>.*//'` #This is the substring between < and >. Это подстрока между < и >
				tmp_str=`echo "$b_str2" | sed 's/\//./g'` #Replace / with . not to confuse sed. Заменяем / на . чтобы не сбивать с толку sed
				b_str3=`echo "$b_str0" | sed "s/${tmp_str}.//"` #This is the substring after >. Это подстрока после >
				b_str2="${add_slash}${b_str2}"
			else #This line contains < in the middle. Это строка содержит < в середине
				b_str1=`echo "$b_inp" | sed 's/<.*//'` #This is the substring before <. Это подстрока до <
				tmp_str=`echo "$b_str1" | sed 's/\//./g'` #Replace / with . not to confuse sed. Заменяем / на . чтобы не сбивать с толку sed
				b_str0=`echo "$b_inp" | sed "s/${tmp_str}.//"`
				if [[	$b_str0 =~ ^\/.* ]] ; then #Это закрывающий тэг </ >
					add_slash="/"
					b_str0=`echo "$b_str0" | sed "s/\///"`
				else
					add_slash=""
				fi
				b_str2=`echo "$b_str0" | sed 's/>.*//'` #подстрока между < и >
				tmp_str=`echo "$b_str2" | sed 's/\//./g'` #Replace / with . not to confuse sed. Заменяем / на . чтобы не сбивать с толку sed
				b_str3=`echo "$b_str0" | sed "s/${tmp_str}.//"` #подстрока после >
				b_str2="${add_slash}${b_str2}"
			fi
			if [[	$b_str1 =~ [A-Za-z]+ ]] ;
			then
				#b_trans_ted=$b_trans_ted`trans en:ru -b -no-autocorrect -e google "$b_str1" `
				b_trans_ted=${b_trans_ted}$(c_tr "$b_str1") #Substring before < send further for translation. Подстроку до < отправляем дальше для перевода, если в ней есть буквы
				b_trans_ted=$b_trans_ted" <${b_str2}> "
			else #There are no letters in the substring, so there is nothing to translate. Букв в подстроке нету, так что переводить нечего
				b_trans_ted=$b_trans_ted"$b_str1<${b_str2}>"
			fi
			b_inp=$b_str3 #The rest of the line after > return for analysis. Остаток строки после > вернем на анализ 
		done
		if [[	$b_inp =~ [A-Za-z]+ ]] ;
		then #The rest of the line without <>. Translate if there are letters in the string. Остаток строки без <>. Переводим целиком, если в строке вообще есть буквы
			#b_trans_ted=$b_trans_ted`trans en:ru -b -no-autocorrect -e google "$b_inp" `
			b_trans_ted=${b_trans_ted}$(c_tr "$b_inp")
		else
			b_trans_ted=$b_trans_ted"$b_inp"
		fi
	else #There are no < > tags. Тэгов < > нет, переводим целиком
		if [[	$b_inp =~ [A-Za-z]+ ]] ;
		then
			#b_trans_ted=`trans en:ru -b -no-autocorrect -e google "$b_inp" `
			b_trans_ted=$(c_tr "$b_inp")
		else
			b_trans_ted="$b_inp"
		fi
	fi
	echo "$b_trans_ted"
	return
}

a_tr () {
	inp="$*"
	if [[	$inp =~ .*\[\[.* ]] ; then #The string contains [[, we will cut. Строка содержит [[, будем резать
		trans_ted=''
		while [[	$inp =~ .*\[\[.* ]]
		do
			if [[	$inp =~ ^\[\[.* ]] ; then #Это строка начавшаяся c [[
				str1=''
				str0=`echo "$inp" | sed "s/\[\[//"`
				str2=`echo "$str0" | sed 's/\]\].*//'` #подстрока внутри [[ и ]]
				tmp_str=`echo "$str2" | sed 's/\//./g'` #Replace / with . not to confuse sed. Заменяем / на . чтобы не сбивать с толку sed
				str3=`echo "$str0" | sed "s/${tmp_str}..//"` #подстрока после ]]
			else
				str1=`echo "$inp" | sed 's/\[\[.*//'` #подстрока до [[
				tmp_str=`echo "$str1" | sed 's/\//./g'` #Replace / with . not to confuse sed. Заменяем / на . чтобы не сбивать с толку sed
				str0=`echo "$inp" | sed "s/${tmp_str}..//"`
				str2=`echo "$str0" | sed 's/\]\].*//'` #подстрока внутри [[ и ]]
				tmp_str=`echo "$str2" | sed 's/\//./g'` #Replace / with . not to confuse sed. Заменяем / на . чтобы не сбивать с толку sed
				str3=`echo "$str0" | sed "s/${tmp_str}..//"` #подстрока после ]]
			fi
			trans_ted=$trans_ted$(b_tr "$str1")" [[${str2}]] "
			inp=$str3
		done
		trans_ted=$trans_ted$(b_tr "$inp")
	else #Переменых вида [[x]] нет, переводим целиком
		trans_ted=$(b_tr "$inp")
	fi
	echo ${prefix}"$trans_ted"${postfix}
	prefix=""
	postfix=""
	return
}

while IFS= read line
do
if [[ $line =~ ^#.*	]] ; then #This is a comment line. Это строка комментария
	echo $line
elif [[ $line =~ ^[_A-Z0-9]{1,100}$ ]] ; then #This is a string with a variable name. Это похоже на строку с именем переменной
	read twice #Read the next line with the contents of the variable. Читаем следующую строку с содержимым переменной
	apostrophe_beg=0
	apostrophe_end=0
	prefix=""
	postfix=""
	if [[	$twice =~ ^\'\'\'?.*\'\'\'$ ]] ; then #This is a string that starts and ends with a triple quote. Это строка начавшаяся и закончившаяся тройной кавычкой
		apostrophe_beg=1
		apostrophe_end=1
		prefix="'''"
		postfix="'''"
	elif [[	$twice =~ ^\'\'\'.* ]] ; then #This is a string that starts with a triple quote. Это строка начавшаяся тройной кавычкой
		apostrophe_beg=1 #поскольку только что был заголовок - это отрывающие кавычки
		prefix="'''"
	fi
	if ((apostrophe_beg==1)) || ((apostrophe_end==1)) ; then #The string twice contains at least one triple quote. Строка twice содержит хоть одну тройную кавычку
		twice=`echo "$twice" | tr -d "'''"`  #Remove the triple quotes from twice, but we remember where they were. Cтрока twice, из которой убраны тройные кавычки, но мы записали, где они были
	fi	
	echo $line
	a_tr "$twice" #We send the twice for translation. Отправляем строку twice на причесывание и перевод
	while ((apostrophe_beg==1)) && ((apostrophe_end==0)) #If there was an opening triple quote and there was no closing one, then until the closing one appears, the lines of the same variable continue. Если была открывающая тройная кавычка и не было закрывающей, то пока не появится закрывающая продолжаются строки той-же переменной
	do
		read third
		if [[ $third =~ .*\'\'\'$ ]] ; then #Found the closing triple quote. Нашли закрывающую тройную кавычку
			apostrophe_end=1
			postfix="'''"
			third=`echo "$third" | tr -d "'''"`  #Remove the triple quotes from third, but we remember where they were. Это строка third, из которой убраны тройные кавычки, но мы запомним, что они были
		fi
		a_tr "$third" #We send the twice for translation. Отправляем строку на причесывание и перевод
	done

else #Empty line. Это не комментарий и не имя переменной и не строки с текстом переменной. Так что просто выведем как есть. Скорее всего это пустая строка
	echo $line
fi
#Source text file. No need to change. Файл с исходным текстом. Менять не надо.
done <./en.txt
