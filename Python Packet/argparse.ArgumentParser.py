'''
    ~]$ python argparse.ArgumentParser.py
    usage: [-h] [-a PARA] [-b PARB]
    ~]$ python argparse.ArgumentParser.py -h
    usage: temp.py [-h] [-a PARA] [-b PARB]

    喂我两个数字，我就吐出他们的积

    optional arguments:
      -h, --help            show this help message and exit
      -a PARA, --ParA PARA  我是A
      -b PARB, --ParB PARB  我是B
    ~]$ python argparse.ArgumentParser.py -a 3 -b 99
    啊，两个都吃到啦！积是 99
'''

from argparse import ArgumentParser


parser = ArgumentParser()
parser.description = '喂我两个数字，我就吐出他们的积'
parser.add_argument(
    "-a",
    "--ParA",
    help="我是A",
    type=int)
parser.add_argument(
    "-b",
    "--ParB",
    help="我是B",
    type=int)
args = parser.parse_args()
if args.ParA and not args.ParB:
    print("我只吃到了A，它是", args.ParA)
elif args.ParB and not args.ParA:
    print("我只吃到了B，它是", args.ParB)
elif args.ParA and args.ParB:
    print("啊，两个都吃到啦！积是", args.ParA * args.ParB)
else:
    print('usage: [-h] [-a PARA] [-b PARB]')
