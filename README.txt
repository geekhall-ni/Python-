Usage :
    求解布局：  python main.py -n <netlist> -c <cell_name> -o <save_path>
    可视化结果：python visualize.py <save_path> (需要安装opencv-python)

注意：
# 改了多个文件顶部注释的路径
# visualize.py中，增加图片中文字的的清晰度


这是两个使用命令:

# 求解布局命令
case1:
    python main.py -n C:\Users\Defender\Desktop\commit\cells.spi -c AN2D2 -o C:\Users\Defender\Desktop\commit\placement_data.json
case2:
    python main.py -n C:\Users\Defender\Desktop\commit\cells.spi -c AN3D2 -o C:\Users\Defender\Desktop\commit\placement_data.json

# 可视化结果命令
    python visualize.py C:\Users\Defender\Desktop\commit\placement_data.json



