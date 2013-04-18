def getRangeFromId(ranges, id):
	return theRightThing

def getTableFromString(string):
	return theTable

def revCompSelection(spans , spanStartOffset, spanEndOffset):
	first = []
	middle = []
	last = []
	start = 0
	end = 0



	#handle first span
	if spans.len > 0:
		first = spans[0]
		feat = first[0]
		data-features = getTableFromString(first.data-features)
		data-offsets = getTableFromString(first.data-offsets)
		rangey = getRangeFromId(feat.location.ranges, data-features[feat.id])
		rangeOffset = data-offsets[feat.id] + spanStartOffset
		start = rangey.start + rangeOffset
		end = window.getSelection().toString().len + start

		modifiedFeats = []

		for feat in first.features:
			rangey = getRangeFromId(feat.location.ranges, data-features[feat.id])
			rangeOffset = data-offsets[feat.id] + spanStartOffset
			ret = splitFeatureAt(feat.id, rangey.id, rangeOffset)
			modifiedFeats.append(ret.new)

		for feat in modifiedFeats:
			oldRange = feat.location.ranges[0]
			length = oldRange.end - oldRange.start
			oldRange.start = end - length
			oldRange.end = end

	if spans.len > 1:
		last = spans[-1]

	if spans.len > 2:
		middle = spans[1 , spans.len - 2]



	
