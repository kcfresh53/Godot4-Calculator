# This is not _optimized_ for GDScript, but it works
# Adapted from: stackoverflow.com/q/21418892/understanding-super-fast-blur-algorithm

static func fast_blur(img: Image, radius: int) -> Image:
	if radius < 1:
		return img
	
	var w: int = img.get_width()
	var h: int = img.get_height()
	var wm: int = w - 1
	var hm: int = h - 1
	var wh: int = w * h
	var div: int = radius + radius + 1
	var r := PackedInt32Array()
	r.resize(wh)
	var g := PackedInt32Array()
	g.resize(wh)
	var b := PackedInt32Array()
	b.resize(wh)
	var rsum: int
	var gsum: int
	var bsum: int
	var p: int
	var p1: int
	var p2: int
	var yp: int
	var yi: int
	var yw: int
	var vmin := PackedInt32Array()
	vmin.resize(max(w, h))
	var vmax := PackedInt32Array()
	vmax.resize(max(w, h))
	var pix := PackedInt32Array()
	pix.resize(w * h)
	pix.fill(0)
	
	for x in w:
		for y in h:
			# This algorithm uses argb, while Godot's Color uses rgba
			pix[y * w + x] = img.get_pixel(x, y).to_argb32()
	
	var dv := PackedInt32Array()
	dv.resize(256 * div)
	for i in 256 * div:
		dv[i] = (i / div)
	
	yw=0
	yi=0
	
	for y in h:
		rsum = 0
		gsum = 0
		bsum = 0
		for i in range(-radius, radius + 1):
			p = pix[yi + min(wm, max(i, 0))]
			rsum += (p & 0xff0000)>>16
			gsum += (p & 0x00ff00)>>8
			bsum +=  p & 0x0000ff
		
		for x in w:
			r[yi] = dv[rsum]
			g[yi] = dv[gsum]
			b[yi] = dv[bsum]
			
			if y==0:
				vmin[x] = min(x + radius + 1, wm)
				vmax[x] = max(x - radius, 0)
			
			p1 = pix[yw + vmin[x]]
			p2 = pix[yw + vmax[x]]
			
			rsum += ((p1 & 0xff0000)-(p2 & 0xff0000))>>16
			gsum += ((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8
			bsum +=  (p1 & 0x0000ff)-(p2 & 0x0000ff)
			yi += 1
		
		yw += w
	
	
	for x in w:
		rsum = 0
		gsum = 0
		bsum = 0
		yp = -radius * w
		for i in range(-radius, radius + 1):
			yi = max(0, yp) + x
			rsum += r[yi]
			gsum += g[yi]
			bsum += b[yi]
			yp += w
		
		yi = x
		for y in h:
			pix[yi]=0x000000ff | (dv[rsum]<<24) | (dv[gsum]<<16) | (dv[bsum]<<8)
			if x==0:
				vmin[y] = min(y + radius+1, hm) * w
				vmax[y] = max(y - radius, 0) * w
			
			p1 = x + vmin[y]
			p2 = x + vmax[y]
			
			rsum += r[p1] - r[p2]
			gsum += g[p1] - g[p2]
			bsum += b[p1] - b[p2]
			
			yi += w
	
	for x in w:
		for y in h:
			img.set_pixel(x, y, Color(pix[y * w + x]))
	
	return img
