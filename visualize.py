'''
Author       : luoweiWHUT 1615108374@qq.com
Date         : 2023-11-23 13:04:26
LastEditors  : luoweiWHUT 1615108374@qq.com
LastEditTime : 2023-11-23 13:04:33
FilePath     : C:\\Users\\Defender\\Desktop\\commit\\visualize.py
Description  : 
'''
from enum import Enum
import cv2
import numpy


class ChannelType(Enum):
    NMOS = 0,
    PMOS = 1


class Mos:
    __slots__ = ('name', 'x', 'y', 'source', 'drain', 'width')

    def __init__(self, name, x, y, source, drain, width):
        self.name = name
        self.x = x
        self.y = y
        self.source = source
        self.drain = drain
        self.width = width

    def __lt__(self, other):
        if self.x == other.x:
            return self.y > other.y
        else:
            return self.x < other.x

    def __str__(self):
        return f"'name':{self.name},'x':{self.x}, 'y':{self.y}, 'source':{self.source}, 'drain':{self.drain}, 'width:{self.width}'"


if __name__ == "__main__":
    import sys
    import json
    if len(sys.argv) < 2:
        print("ERROR: No placement file provided.")
        exit()
    placement_file = sys.argv[1]
    with open(placement_file, 'r') as f:
        placement_data = json.load(f)
    mos_lenth = 60
    unit = 50
    real_x_max = 100+unit*len(placement_data['placement'])
    result = numpy.full((640, real_x_max, 3), 255, numpy.uint8)
    mos_list = [Mos(name, int(mos['x']), int(mos['y']), mos['source'], mos['drain'], int(
        mos['width'])) for name, mos in placement_data['placement'].items()]
    # visulize
    cv2.rectangle(result, (10, 70), (real_x_max-10, 100), (255, 0, 0), 2)
    cv2.rectangle(result, (10, 560), (real_x_max-10, 590), (255, 0, 0), 2)
    cv2.putText(result, 'VDD', (10, 100), None, 1.5, (0, 0, 255), thickness=2, lineType=cv2.LINE_8, bottomLeftOrigin=None)
    cv2.putText(result, 'VSS', (10, 590), None, 1.5, (0, 0, 255), thickness=2, lineType=cv2.LINE_8, bottomLeftOrigin=None)
    cv2.line(result, (10, 330), (real_x_max-10, 330),
             (0, 0, 0), 1, cv2.LINE_AA)
    for mos in mos_list:
        real_x = mos.x*unit+100
        rect = ((real_x, 110+mos.width//2 if mos.y == 1 else 550 -
                mos.width//2), (mos_lenth, mos.width), 0)
        box = numpy.int32(cv2.boxPoints(rect))
        cv2.drawContours(result, [box], -1, (0, 165, 255), 2)
        rect = ((real_x, 330), (5, 480), 0)
        box = numpy.int32(cv2.boxPoints(rect))
        cv2.drawContours(result, [box], -1, (0, 255, 0), -1)
        text_size, _ = cv2.getTextSize(mos.name, None, 0.3, 1)
        cv2.putText(result, mos.name, (real_x-text_size[0]//2, 80+text_size[1]//2 if mos.y == 1 else 580 +
                    text_size[1]//2), None, 0.5, (0, 0, 0), thickness=1, lineType=cv2.LINE_8, bottomLeftOrigin=None)
    # cv2.imshow("result", result)  # 显示窗口
    # cv2.waitKey(0)  # 等待按键
    # cv2.destroyAllWindows()  # 释放窗口
    cv2.imwrite('result.jpg', result)
    print("可视化结果已保存至./result.jpg")
