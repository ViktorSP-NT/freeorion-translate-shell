# freeorion-translate-shell
### This is freeorions translate script.

### Usage
This is the language file translation script for the FreeOrion game (https://freeorion.org)

If the game does not have a language file for your language (or it is outdated, which is quite possible given the ongoing development of the game), use this script.

Before using the translation script, obtain a file with English texts, for example, by installing the FreeOrion game (https://github.com/freeorion/freeorion/releases) and rummaging through the stringtables directory.

For the script to work, you need to install the translate-shell application: https://github.com/soimort/translate-shell
Before running the script, open freeorion.sh for editing, replace ru with your language code.

Make the script executable

'''chmod +x freeorion.sh'''

To run the script, go to its folder and run like this:

'''./freeorion.sh >> [your language code].txt'''

The translate-shell app allows you to use a translation engine from different companies. To use a different one, replace in frreorion.sh google with the name of another translator. The list of available translators can be viewed by running in the console

'''trans -S'''



### Это скрипт перевода языкового файла игры FreeOrion (https://freeorion.org)

Если в игре нет языкового файла вашего языка (или он устарел, что вполне возможно, учитывая продолжающуюся разработку игры), используйте этот скрипт.

Перед использованием скрипта перевода добудьте файл с текстами английского языка, например, установив игру FreeOrion (https://github.com/freeorion/freeorion/releases) и порывшись в директории stringtables.

Для работы скрипта необходимо установить приложение translate-shell: https://github.com/soimort/translate-shell 
Перед запуском скрипта откройте freeorion.sh на редактирование, замените ru кодом вашего языка. 

Сделайте скрипт исполняемым 

'''chmod + х freeorion.sh'''

Для запуска скрипта перейдите в его папку и запустите так:

'''./freeorion.sh >> [код вашего языка].txt'''

Приложение translate-shell позволяет использовать механизм перевода от разных компаний. Чтобы использовать другой замените в frreorion.sh google на название другого переводчика. Список доступных переводчиков можно посмотреть выполнив в консоли 

'''trans -S'''
