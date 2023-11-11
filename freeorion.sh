#!/bin/bash
#For this script to work, you must first install translate_shell (https://github.com/soimort/translate-shell). для работы данного скрипта необходимо предварительно установить translate_shell (https://github.com/soimort/translate-shell)
#Run the script with the command (without quotes) "./freeorion.sh >> [your language code].txt". Запуск скрипта командой (без кавычек) "./freeorion.sh >> [your language code].txt"
d_tr () {
#Call to translator there. Тут обращаемся к переводчику
	d_inp="$*"
	if [[	$d_inp =~ ^\s.* ]] ; then
		Beg_space=" " 
	else
		Beg_space=""
	fi
	if [[	$d_inp =~ .*\s$ ]] ; then
		End_space=" "
	else
		End_space=""
	fi
#Replacing abbreviations with more understandable texts. Add your own or delete if you want. Замена сокращений на более понятные тексты. Допишите своё или удалите, если хотите
	d_inp=`echo "$d_inp" | sed 's/ PP/ Productions Points/g'`
	d_inp=`echo "$d_inp" | sed 's/ uu/ light years/g'`
	d_inp=`echo "$d_inp" | sed 's/(uu/(light years/g'`
#Translating text with the translate-shell utility. Собственно перевод текста утилитой translate-shell
#Specify after en: the language you want to translate into. Specify the translation engines after -e. The list of available translation engines can be viewed by typing "trans -S" in the console. 
#Укажите после en: язык на который хотите перевести. Укажите после -e переводчик. Список переводчиков можно посмотреть введя в консоли trans -S
	d_trans_ted=`trans en:ru -b -no-auto -e google "$d_inp" `
	echo "${Beg_space}${d_trans_ted}${End_space}"
	return
}

c_tr () {
#Processing text in %xxx% tags. Обработка текста в %xxx% тэгах
	c_inp="$*"
	if [[	$c_inp =~ .*%[^\s]*%.* ]] ; then #echo "The line contains tags, we will cut. Строка содержит тэги, будем резать"
		c_trans_ted=''
		while [[	$c_inp =~ .*%[^\s]*%.* ]] #While line contains tags %%, we will cut. Пока есть фрагменты типа %%
		do
			#This line contains tag %% in the middle. Это строка содержит тэги %% в середине
			c_str1=`echo "$c_inp" | sed 's/%.*%.*//'` #This is the substring before %. Это подстрока до первого %
			tmp_str=`echo "$c_str1" | sed 's/\//./g'` #Replace in c_str1 / with . not to confuse sed. Заменяем в c_str1 все / на . (один любой символ) чтобы не сбивать с толку sed
			c_str0=`echo "$c_inp" | sed "s/${tmp_str}.//"` #substring from first % to end string. выкидываем из первоначальной строки c_str1, остается остаток строки начиная с содержимого первых тегов %%
			c_str2=`echo "$c_str0" | sed 's/%.*//'` #string in the first tag %%. содержимое первого тэга %% начальной строки
			tmp_str=`echo "$c_str2" | sed 's/\//./g'` #Replace / with . not to confuse sed. Заменяем в содержимом тэга %% все / на . (один любой символ) чтобы не сбивать с толку sed
			c_str3=`echo "$c_str0" | sed "s/${tmp_str}.//"` #substring from end of first tag %% to end string. то, что осталось от первоначальной строки, после того, как из неё выкинули начало включая первый тэг %, это возвращаем на дальнейший анализ, как новую строку
			if [[	$c_str1 =~ [A-Za-z]+ ]] ;
			then
				c_trans_ted=${c_trans_ted}" "$(d_tr "$c_str1")" " #Substring before %% send further for translation. Подстроку до %% отправляем дальше для перевода, если в ней есть буквы
				c_trans_ted=$c_trans_ted"%${c_str2}%"  #+ содержимое тэга %%
			else #There are no letters in the substring, so there is nothing to translate. Букв в подстроке нету, так что переводить нечего
				c_trans_ted=$c_trans_ted"$c_str1%${c_str2}%"  #содержимое тэга %%
			fi
			c_inp=$c_str3 #The rest of the line after tag %%. Return it for analysis. Остаток строки после тэга %% вернем на дальнейший анализ 
		done
		if [[	$c_inp =~ [A-Za-z]+ ]] ;
		then #The rest of the line without all tag %%. Translate if there are letters in the string. Остаток строки после всех тэгов %%. Переводим целиком, если в строке вообще есть буквы
			#b_trans_ted=$b_trans_ted`trans en:ru -b -no-autocorrect -e google "$b_inp" `
			c_trans_ted=${c_trans_ted}" "$(d_tr "$c_inp")
		else
			c_trans_ted=$c_trans_ted"$c_inp"
		fi
	else #There are no %% tags. Тэгов %% нет, переводим целиком
		if [[	$c_inp =~ [A-Za-z]+ ]] ;
		then
			c_trans_ted=$(d_tr "$c_inp")
		else
			c_trans_ted="$c_inp"
		fi
	fi
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
				b_trans_ted=$b_trans_ted"<${b_str2}>"
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
#Processing text in [[xxx]] tags. Обработка текста в [[xxx]] тэгах
	inp="$*"
	if [[	$inp =~ .*\[\[.* ]] ; then #The string contains [[, we will cut. Строка содержит [[, будем резать
		trans_ted=''
		while [[	$inp =~ .*\[\[.* ]]
		do
			if [[	$inp =~ ^\[\[.* ]] ; then #Substring from [[. Это строка начавшаяся c [[
				str1=''
				str0=`echo "$inp" | sed "s/\[\[//"`
				str2=`echo "$str0" | sed 's/\]\].*//'` #Substring in [[ ]]. подстрока внутри [[ и ]]
				tmp_str=`echo "$str2" | sed 's/\//./g'` #Replace / with . not to confuse sed. Заменяем / на . чтобы не сбивать с толку sed
				str3=`echo "$str0" | sed "s/${tmp_str}..//"` #Substring after ]]. подстрока после ]]
			else
				str1=`echo "$inp" | sed 's/\[\[.*//'` #Substring before [[. подстрока до [[
				tmp_str=`echo "$str1" | sed 's/\//./g'` #Replace / with . not to confuse sed. Заменяем / на . чтобы не сбивать с толку sed
				str0=`echo "$inp" | sed "s/${tmp_str}..//"`
				str2=`echo "$str0" | sed 's/\]\].*//'` #Substring in [[ ]]. подстрока внутри [[ и ]]
				tmp_str=`echo "$str2" | sed 's/\//./g'` #Replace / with . not to confuse sed. Заменяем / на . чтобы не сбивать с толку sed
				str3=`echo "$str0" | sed "s/${tmp_str}..//"` #Substring after ]]. подстрока после ]]
			fi
			trans_ted=$trans_ted$(b_tr "$str1")" [[${str2}]] "
			inp=$str3
		done
		trans_ted=$trans_ted$(b_tr "$inp")
	else #String not contain tag [[x]], will translate whole. Тэгов [[x]] в строке нет, переводим целиком
		trans_ted=$(b_tr "$inp")
	fi
	echo ${prefix}"$trans_ted"${postfix}
	prefix=""
	postfix=""
	return
}


#Looping through lines. Перебор строк
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
		apostrophe_beg=1 #поскольку только что был заголовок - это открывающие кавычки
		prefix="'''"
	fi
	if ((apostrophe_beg==1)) || ((apostrophe_end==1)) ; then #The string twice contains at least one triple quote. Строка twice содержит хоть одну тройную кавычку
		twice=`echo "$twice" | tr -d "'''"`  #Remove the triple quotes from twice, but we remember where they were. Cтрока twice, из которой убраны тройные кавычки, но мы записали, где они были
	fi	
	echo $line
	a_tr "$twice" #We send the twice for analiz and translation. Отправляем строку twice на причесывание и перевод
	while ((apostrophe_beg==1)) && ((apostrophe_end==0)) #If there was an opening triple quote and there was no closing one, then until the closing one appears, the lines of the same variable continue. Если была открывающая тройная кавычка и не было закрывающей, то пока не появится закрывающая продолжаются строки той-же переменной
	do
		read third
		if [[ $third =~ .*\'\'\'$ ]] ; then #Found the closing triple quote. Нашли закрывающую тройную кавычку
			apostrophe_end=1
			postfix="'''"
			third=`echo "$third" | tr -d "'''"`  #Remove the triple quotes from third, but we remember where they were. Это строка third, из которой убраны тройные кавычки, но мы запомним, что они были
		fi
		a_tr "$third" #We send the third for translation. Отправляем строку на причесывание и перевод
	done

else #Empty line. Это не комментарий и не имя переменной и не строки с текстом переменной. Так что просто выведем как есть. Скорее всего это пустая строка
	echo $line
fi
#Path to english source stringtables text file. Файл с исходными текстами на английском. Именно его и будем переводить. Возьмите его из директории stringtables игры FreeOrion
done <./en.txt
