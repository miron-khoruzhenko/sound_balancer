# Краткое описание
- Скрипт принимает один аргумент `--sound-up` или `--sound-down` для увеличения и уменьшения звука соответственно. 
- Благодаря этим аргументам можно привязать скрипт к клавишам звука
	- Пример: `sound_balancer --sound-up`
- Внутри программы есть переменная `desired_difference` которая отвечает за баланс. Изменяя ее можно настроить баланс под себя.
- Скрипт увеличивает или уменьшает звук на **5%**. Это можно изменить в этой строке:
	- `let "right_volume=$current_right_volume $my_operator one_percent*5"`
	
## Важные данные
- **Коэффициент разницы уровня звука:** 0.825 от левого к правому
- **Абсолютные значения**:
	- Максимальное 158% или 99957 или 11.0 dB
	- Стандартное 100% или 65536 или 0.00 dB
	- Минимальное 0% или 0 или -inf dB
	- Учитывая данные выше можно сказать что 1% примерно равен 655.36
- **Важные команды:**
	- `pactl list sinks short` - для получения информации о устройствах вывода и их **id**
	- `pactl get-sink-volume [sink_id]` - для получение информации о громкости выводе звука
	- `pactl set-sink-volume [sink_id] {value1,value2}` - для установки громкости звука
- Предыдущие горячие клавиши:
	- ![[Pasted image 20240412003824.png]]

# Определение проблемы
Из за возможной проблемы с моим левым ухом на большинстве устройств мне приходиться настраивать баланс правого и левого уха и особо проблем не возникает. Однако на Fedora XFCE используя **"Pasystray"** баланс можно настроить только в виде разницы между громкостью правого и левого вывода. Проблема состоит в том что разница это должна увеличиваться на большой громкости и уменьшаться на маленькой то есть меняться линейно. 

# Ход мысли и решение
## Определение коэффициента 
Что бы проверить свою теорию я на слух определил несколько уровней звука на разных величинах громкости, записал значения правого и левого вывода и построил график (**Graph 1)**. На нем явно видно что есть некий коэффициент разницы громкости а точнее для меня **0.825**.

![[Pasted image 20240412024618.png]]

То есть что бы постоянно иметь сбалансированный звук можно просто менять звук по этой простой формуле:
$$\displaylines{
Left\ Volume = Right\ Volume × 0.825
}$$
## Получение данных звука
После того как мы определились с алгоритмом осталось получить данные звука для изменения. Для всех действий со звуком я использовал команду `pactl`.

Для начала определим источником вывода с которым мы будем работать. Прописав команду `pactl list sinks short` мы можем увидеть наши устройства и их **ID.**

```zsh
$pactl list sinks short
52	alsa_output.pci-0000_00_1b.0.analog-stereo	PipeWire	s32le 2ch 48000Hz	RUNNING
```

Однако чуть позже я увидел что **ID** меняется со временем по этому решил использовать имя устройства. В моем случае это `alsa_output.pci-0000_00_1b.0.analog-stereo`. 

Далее мне нужно получить величину громкости на данный момент. Для этого я использую команду `pactl get-sink-volume`. Вот так она выглядит в терминале:
```zsh
➜  ~ pactl get-sink-volume alsa_output.pci-0000_00_1b.0.analog-stereo
Volume: front-left: 54394 /  83% / -4.86 dB,   front-right: 65536 / 100% / 0.00 dB
        balance 0.17
```

С помощью инструментов консоли  я отделяю нужную мне часть с данными **Правого Вывода**:
```zsh
➜  ~ pactl get-sink-volume alsa_output.pci-0000_00_1b.0.analog-stereo | awk '{print $10}' | sed 's/%//g'
65536
```

Тут можно заметить два момента:
- `awk '{print $10}'` - берет `65536` из вывода и при изменении числа **10** на другое можно взять другие данные.
- ` sed 's/%//g'` - заменяет `%` 

Используя эти единицы в отличии от процента я могу более точно изменять громкость. Учитывая что эта громкость у меня при **100%** то можно принять что **1%** будет равен примерно **665.36**. 

Далее используя эти данные и простую математику можно определить громкость для правого и левого вывода а так же добавлять или уменьшать громкость добавляя или уменьшая значение у правого.

Далее можно почитать как сделать [[2024.04.12-global-script-creation |скрипт глобальным]]. Вот ссылка на [онлайн версию](https://gist.github.com/miron-khoruzhenko/6ba450bb9ae12c1f2d0874f730d40cf4)
