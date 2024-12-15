from PIL import Image, ImageDraw
import os

def rounded_rectangle(draw, coords, radius, fill):
    x1, y1, x2, y2 = coords
    diameter = 2 * radius
    
    # 绘制主矩形
    draw.rectangle([x1 + radius, y1, x2 - radius, y2], fill=fill)
    draw.rectangle([x1, y1 + radius, x2, y2 - radius], fill=fill)
    
    # 绘制四个圆角
    draw.ellipse([x1, y1, x1 + diameter, y1 + diameter], fill=fill)
    draw.ellipse([x2 - diameter, y1, x2, y1 + diameter], fill=fill)
    draw.ellipse([x1, y2 - diameter, x1 + diameter, y2], fill=fill)
    draw.ellipse([x2 - diameter, y2 - diameter, x2, y2], fill=fill)

def create_icon(size):
    # 创建新图像，使用RGBA模式支持透明度
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # 计算尺寸
    padding = size * 0.1
    center = size / 2
    radius = (size - 2 * padding) / 2
    
    # 绘制主圆形背景
    draw.ellipse(
        [padding, padding, size - padding, size - padding],
        fill='#2196F3'
    )
    
    # 绘制串口连接器形状
    connector_height = size * 0.3
    connector_width = size * 0.6
    connector_x = (size - connector_width) / 2
    connector_y = (size - connector_height) / 2
    
    # 绘制白色连接器
    rounded_rectangle(
        draw,
        [connector_x, connector_y, 
         connector_x + connector_width, 
         connector_y + connector_height],
        size * 0.05,
        '#FFFFFF'
    )
    
    # 绘制数据流线条
    line_spacing = connector_height / 3
    line_y1 = connector_y + line_spacing
    line_y2 = connector_y + 2 * line_spacing
    
    draw.line(
        [connector_x + size * 0.1, line_y1,
         connector_x + connector_width - size * 0.1, line_y1],
        fill='#2196F3',
        width=max(1, int(size * 0.02))
    )
    
    draw.line(
        [connector_x + size * 0.1, line_y2,
         connector_x + connector_width - size * 0.1, line_y2],
        fill='#2196F3',
        width=max(1, int(size * 0.02))
    )
    
    return image

# 生成所有需要的尺寸
sizes = [16, 32, 128, 256, 512, 1024]
output_dir = "AppIcon.appiconset"

# 创建输出目录
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# 生成各种尺寸的图标
for size in sizes:
    icon = create_icon(size)
    icon.save(f"{output_dir}/icon_{size}x{size}.png")
    
    # 生成 @2x 版本
    if size < 512:  # 1024 不需要 @2x
        icon2x = create_icon(size * 2)
        icon2x.save(f"{output_dir}/icon_{size}x{size}@2x.png")

print("图标生成完成！")
