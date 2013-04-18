(function() {
  var GenBank,
    __hasProp = {}.hasOwnProperty;

  if (!String.prototype.format) {
    String.prototype.format = function() {
      var args;
      args = arguments;
      return this.replace(/{(\d+)}/g, function(match, number) {
        if (typeof args[number] !== 'undefined') {
          return args[number];
        } else {
          return match;
        }
      });
    };
  }

  String.prototype.padBy = function(length) {
    var pad, retval;
    pad = length - this.length;
    retval = this;
    while (pad > 0) {
      retval = retval.concat(" ");
      pad -= 1;
    }
    return retval;
  };

  window.G || (window.G = {});

  window.G.GenBank = GenBank = (function() {

    function GenBank(text, id) {
      var contents, line, lineParts, sectionName, _i, _len, _ref;
      this.text = text;
      this.id = id != null ? id : "default";
      console.groupCollapsed("GenBank Constructor " + this.id);
      this.newline = "\n";
      if (this.text.indexOf("\r\n") !== -1) {
        this.newline = "\r\n";
      } else if (this.text.indexOf("\r") !== -1) {
        this.newline = "\r";
      }
      this.textLines = this.text.split(this.newline);
      this.data = {};
      sectionName = "";
      contents = "";
      console.groupCollapsed("Looking at the lines");
      _ref = this.textLines;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (line[0] !== " ") {
          if (sectionName !== "") {
            console.debug("Found section " + sectionName);
            this.data[sectionName] = contents;
            contents = "";
          }
          lineParts = line.split(/[ ]+/);
          sectionName = lineParts[0];
          if (lineParts.length > 1) {
            if (sectionName !== "LOCUS") {
              contents = lineParts.slice(1).join(" ");
            } else {
              contents = {
                name: lineParts[1],
                length: lineParts[2],
                type: lineParts.slice(4, 6).join(" "),
                division: lineParts[6],
                date: lineParts[7]
              };
            }
          }
        } else if (sectionName !== "") {
          if (contents === "") {
            contents = line;
          } else {
            contents += this.newline + line;
          }
        }
      }
      console.groupEnd();
      console.groupEnd();
    }

    GenBank.prototype.annotateOld = function(sequence, start, end, color, name, spanId, featureId) {
      var beg, count, current, endix, mid, startix, x, _i, _ref;
      console.groupCollapsed("Adding annotation " + featureId + "-" + spanId + " to sequence: (" + start + ".." + end + ")");
      if (typeof start !== "number") {
        start = parseInt(start) - 1;
      }
      if (typeof end !== "number") {
        end = parseInt(end) - 1;
      }
      count = true;
      current = 0;
      startix = -1;
      endix = -1;
      for (x = _i = 0, _ref = sequence.length; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        if (sequence[x] === "<") {
          count = false;
        }
        if (current === start) {
          startix = x;
        }
        if (current === end) {
          endix = x;
        }
        if (count) {
          current += 1;
        }
        if (sequence[x] === ">") {
          count = true;
        }
      }
      if (startix === -1 || endix === -1) {
        console.error("End index or start index not found...", startix, endix);
        if (current === start) {
          startix = x;
        }
        if (current === end) {
          endix = x;
        }
      }
      console.log(startix, endix);
      beg = sequence.slice(0, startix);
      end = sequence.slice(endix + 1);
      mid = sequence.slice(startix, +endix + 1 || 9e9);
      console.groupEnd();
      return beg + ("<span id='" + name + "-" + featureId + "-" + spanId + "-" + this.id + "' class='" + name + "-" + featureId + "' style='background-color:" + color + "'>") + mid + "</span>" + end;
    };

    GenBank.prototype.annotateFeature = function(seq, feature) {
      var color, name, span, _i, _len, _ref;
      console.groupCollapsed("Annotating the feature: ", feature);
      color = feature.parameters["/ApEinfo_fwdcolor"];
      if (feature.location.strand === 1) {
        color = feature.parameters["/ApEinfo_revcolor"];
      }
      name = feature.parameters["/label"];
      _ref = feature.location.ranges;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        span = _ref[_i];
        seq = this.annotateOld(seq, span.start, span.end, color, name, span.id, feature.id);
      }
      console.groupEnd();
      return seq;
    };

    GenBank.prototype.annotate = function(sequence, start, end, color, features, id) {
      var beg, count, current, data_features, data_offsets, endix, feat, mid, offset, parts, span, startix, x, _i, _j, _len, _ref;
      console.groupCollapsed("Adding annotation " + id + " to sequence: (" + start + ".." + end + ")");
      if (typeof start !== "number") {
        start = parseInt(start) - 1;
      }
      if (typeof end !== "number") {
        end = parseInt(end) - 1;
      }
      count = true;
      current = 0;
      startix = -1;
      endix = -1;
      for (x = _i = 0, _ref = sequence.length; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        if (sequence[x] === "<") {
          count = false;
        }
        if (current === start) {
          startix = x;
        }
        if (current === end) {
          endix = x;
        }
        if (count) {
          current += 1;
        }
        if (sequence[x] === ">") {
          count = true;
        }
      }
      if (startix === -1 || endix === -1) {
        console.error("End index or start index not found...", startix, endix);
        if (current === start) {
          startix = x;
        }
        if (current === end) {
          endix = x;
        }
      }
      console.log(startix, endix);
      beg = sequence.slice(0, startix);
      end = sequence.slice(endix + 1);
      mid = sequence.slice(startix, +endix + 1 || 9e9);
      data_features = "";
      data_offsets = "";
      for (_j = 0, _len = features.length; _j < _len; _j++) {
        parts = features[_j];
        feat = parts.feature;
        span = parts.range;
        offset = start - span.start;
        if (data_features !== "") {
          data_features += ",";
          data_offsets += ",";
        }
        data_features += "" + feat.id + ":" + span.id;
        data_offsets += "" + feat.id + ":" + offset;
      }
      console.groupEnd();
      return beg + ("<span id='" + id + "-" + this.id + "' style='background-color:" + color + "' data-offsets='" + data_offsets + "' data-features='" + data_features + "'>") + mid + "</span>" + end;
    };

    GenBank.prototype.annotateRange = function(seq, range, i) {
      var color, feat, name, r, span;
      if (i == null) {
        i = 0;
      }
      console.groupCollapsed("Annotating range: ", range);
      r = range.feats[range.feats.length - 1];
      feat = r.feature;
      span = r.range;
      console.log("The feature: ", feat, "is on top");
      color = feat.parameters['/ApEinfo_fwdcolor'];
      if (feat.location.strand === 1) {
        color = feat.parameters['/ApEinfo_revcolor'];
      }
      name = feat.parameters["/label"];
      seq = this.annotate(seq, range.selection.start, range.selection.end, color, range.feats, i);
      console.groupEnd();
      return seq;
    };

    GenBank.findRangeById = function(ranges, spanId) {
      var r, range, _i, _len;
      if (ranges.uid === spanId) {
        return ranges;
      }
      for (_i = 0, _len = ranges.length; _i < _len; _i++) {
        range = ranges[_i];
        r = GenBank.findRangeById(range, spanId);
        if (!!r) {
          return r;
        }
      }
      return null;
    };

    GenBank.prototype.sortByStartIndex = function(a, b) {
      if (a.start === b.start) {
        return 0;
      }
      if (a.start > b.start) {
        return 1;
      } else {
        return -1;
      }
    };

    GenBank.prototype.splitRangeAt = function(featId, rangeId, newLength) {
      var f, r;
      console.groupCollapsed("Splitting range", featId, rangeId, "at", newLength);
      f = this.getFeatures()[featId];
      r = GenBank.getRange(f.location, rangeId);
      f.location.ranges.push({
        start: newLength + 1,
        end: r.end,
        id: f.location.ranges.length
      });
      r.end = newLength;
      f.location.ranges.sort(this.sortByStartIndex);
      console.groupEnd();
      return f;
    };

    GenBank.getSpanData = function(node) {
      var data, feature, features, offset, offsets, split, _i, _j, _len, _len1, _name, _name1;
      offsets = node.getAttribute('data-offsets').split(',');
      features = node.getAttribute('data-features').split(',');
      data = {};
      for (_i = 0, _len = offsets.length; _i < _len; _i++) {
        offset = offsets[_i];
        split = offset.split(':');
        data[_name = split[0]] || (data[_name] = {});
        data[split[0]]['offset'] = parseInt(split[1]);
      }
      for (_j = 0, _len1 = features.length; _j < _len1; _j++) {
        feature = features[_j];
        split = feature.split(':');
        data[_name1 = split[0]] || (data[_name1] = {});
        data[split[0]]['span'] = parseInt(split[1]);
      }
      return data;
    };

    GenBank.prototype.splitFeatureAt = function(featId, rangeId, newLength) {
      var f, newFeat, r, rangeIx;
      console.groupCollapsed("Splitting feature", featId, rangeId, "at", newLength);
      f = this.getFeatures()[featId];
      rangeIx = GenBank.rangeIndex(f, rangeId);
      newFeat = $.extend(true, {}, f);
      newFeat.id = this.getFeatures().length;
      newFeat.location.ranges[rangeIx].start += newLength + 1;
      newFeat.location.ranges = newFeat.location.ranges.slice(rangeIx);
      this.getFeatures().push(newFeat);
      r = f.location.ranges[rangeIx];
      r.end = r.start + newLength;
      f.location.ranges = f.location.ranges.slice(0, +rangeIx + 1 || 9e9);
      console.groupEnd();
      return {
        "new": newFeat,
        old: f
      };
    };

    GenBank.prototype.moveEndBy = function(featId, rangeId, amount) {
      var f, r;
      console.groupCollapsed("Moving end of " + featId + "-" + rangeId);
      f = this.getFeatures()[featId];
      r = GenBank.getRange(f.location, rangeId);
      r.end += amount;
      if (r.end < r.start) {
        f.location.ranges.splice(GenBank.rangeIndex(f, rangeId), 1);
      }
      return console.groupEnd();
    };

    GenBank.prototype.advanceFeature = function(featId, rangeId, amount) {
      var f, r;
      console.groupCollapsed("Advancing " + featId + "-" + rangeId);
      f = this.getFeatures()[featId];
      r = GenBank.getRange(f.location, rangeId);
      r.start += amount;
      r.end += amount;
      return console.groupEnd();
    };

    GenBank.rangeIndex = function(feature, id) {
      var i, range, _i, _len, _ref;
      i = 0;
      _ref = feature.location.ranges;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        range = _ref[_i];
        if (range.id === id) {
          return i;
        }
        i += 1;
      }
    };

    GenBank.getRange = function(location, id) {
      var range, _i, _len, _ref;
      _ref = location.ranges;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        range = _ref[_i];
        if (range.id === id) {
          return range;
        }
      }
      return null;
    };

    GenBank.prototype.getAnnotatedSequence = function() {
      var eq, feature, features, i, j, p, previous, range, rangeId, ranges, s, sel, selection, selections, seq, _i, _j, _k, _l, _len, _len1, _len2, _len3, _m, _n, _ref, _ref1, _ref2, _ref3;
      console.groupCollapsed("Getting Annotated Sequence");
      seq = this.getGeneSequence();
      features = this.getFeatures();
      console.debug("Adding each feature to the sequence");
      selections = new Array(seq.length);
      for (_i = 0, _len = features.length; _i < _len; _i++) {
        feature = features[_i];
        _ref = feature.location.ranges;
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          range = _ref[_j];
          for (i = _k = _ref1 = range.start, _ref2 = range.end; _k <= _ref2; i = _k += 1) {
            if (selections[i] === void 0) {
              selections[i] = [];
            }
            selections[i].push({
              feature: feature,
              range: range
            });
          }
        }
      }
      ranges = [];
      previous = void 0;
      sel = {
        start: 0,
        end: 0
      };
      i = 0;
      for (_l = 0, _len2 = selections.length; _l < _len2; _l++) {
        selection = selections[_l];
        eq = previous !== void 0 && selection !== void 0;
        if (eq && (previous.length !== selection.length)) {
          eq = false;
        }
        if (eq) {
          for (j = _m = 0, _ref3 = selection.length; 0 <= _ref3 ? _m < _ref3 : _m > _ref3; j = 0 <= _ref3 ? ++_m : --_m) {
            s = selection[j];
            p = previous[j];
            if (s.range !== p.range || s.feature !== p.feature) {
              eq = false;
            }
          }
        }
        if (eq) {
          sel.end = i;
        } else {
          if (previous !== void 0) {
            ranges.push({
              feats: previous,
              selection: sel
            });
          }
          previous = selection;
          sel = {
            start: i,
            end: i
          };
        }
        i += 1;
      }
      if (previous !== void 0) {
        ranges.push({
          feats: previous,
          selection: sel
        });
      }
      rangeId = 0;
      for (_n = 0, _len3 = ranges.length; _n < _len3; _n++) {
        range = ranges[_n];
        seq = this.annotateRange(seq, range, rangeId);
        rangeId += 1;
      }
      console.groupEnd();
      return seq;
    };

    GenBank.prototype.getGeneSequence = function() {
      var line, retval, _i, _len, _ref;
      console.groupCollapsed("Getting gene sequence");
      if (this.data.raw_genes != null) {
        console.log("We already calculated the gene sequence");
        console.groupEnd();
        return this.data.raw_genes;
      }
      retval = "";
      _ref = this.data.ORIGIN.split(this.newline);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        retval += line.split(/[ ]*[0-9]* /).slice(1).join("");
      }
      console.debug("Gene sequence constructed");
      console.groupEnd();
      return this.data.raw_genes = retval;
    };

    GenBank.prototype.updateSequence = function(seq) {
      return this.data.raw_genes = seq;
    };

    GenBank.serializeLocation = function(loc) {
      var range, retval, _i, _len, _ref;
      console.groupCollapsed("Serializing Location");
      retval = "";
      _ref = loc.ranges;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        range = _ref[_i];
        console.log("Adding range", range);
        if (retval !== "") {
          retval += ",";
        }
        retval += "" + (range.start + 1) + ".." + (range.end + 1);
      }
      if (loc.ranges.length > 1) {
        console.log("It's a join");
        retval = "join(" + retval + ")";
      }
      if (loc.strand === 1) {
        console.log("It's a complement");
        retval = "complement(" + retval + ")";
      }
      console.groupEnd();
      return retval;
    };

    GenBank.prototype.serialize = function() {
      var contents, file, ignoredSections, section, _ref;
      console.groupCollapsed("Serializing File");
      file = "LOCUS".padBy(12) + this.data.LOCUS.name.padBy(13);
      file += (this.getGeneSequence().length + " bp").padBy(11);
      file += this.data.LOCUS.type.padBy(16) + this.data.LOCUS.division + " ";
      file += this.data.LOCUS.date + this.newline;
      ignoredSections = ["LOCUS", "FEATURES", "ORIGIN", "//", "raw_genes", "features"];
      _ref = this.data;
      for (section in _ref) {
        if (!__hasProp.call(_ref, section)) continue;
        contents = _ref[section];
        if (ignoredSections.indexOf(section) === -1) {
          file += section.padBy(12) + contents + this.newline;
        }
      }
      file += this.serializeFeatures();
      file += this.serializeGenes();
      console.groupEnd();
      return file;
    };

    GenBank.prototype.serializeFeatures = function() {
      var feat, features, key, value, _i, _len, _ref, _ref1;
      console.groupCollapsed("Serializing Features");
      features = "FEATURES             Location/Qualifiers" + this.newline;
      _ref = this.getFeatures();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        feat = _ref[_i];
        if (feat.location.ranges.length > 0) {
          features += "     " + feat.currentFeature.padBy(16) + GenBank.serializeLocation(feat.location) + this.newline;
          _ref1 = feat.parameters;
          for (key in _ref1) {
            if (!__hasProp.call(_ref1, key)) continue;
            value = _ref1[key];
            features += "                     " + ("" + key + "=\"" + value + "\" ") + this.newline;
          }
        }
      }
      console.groupEnd();
      return features;
    };

    GenBank.prototype.serializeGenes = function() {
      var count, genes, group_size, i, increment, j, leading_num, num_digits, num_iter, offset, serialized, spaces, _i, _j, _k, _ref, _ref1;
      count = 0;
      increment = 60;
      group_size = 10;
      offset = 9;
      serialized = "ORIGIN" + this.newline;
      genes = this.getGeneSequence();
      num_iter = Math.ceil(genes.length / (count + increment));
      for (i = _i = 0; _i < num_iter; i = _i += 1) {
        leading_num = i * increment + 1;
        num_digits = Math.floor(Math.log(leading_num) / Math.LN10) + 1;
        for (spaces = _j = 0, _ref = offset - num_digits; _j < _ref; spaces = _j += 1) {
          serialized += " ";
        }
        serialized += leading_num.toString();
        serialized += " ";
        for (j = _k = 0, _ref1 = increment / group_size; _k < _ref1; j = _k += 1) {
          serialized += genes.substring(count, count + 10);
          serialized += " ";
          count += 10;
        }
        serialized += this.newline;
      }
      return serialized + "// " + this.newline;
    };

    GenBank.parseLocationData = function(data) {
      var a, id, isComplement, isJoin, parts, r, ranges, retval, strand, _i, _len, _ref;
      id = 0;
      console.groupCollapsed("Parsing Location Data");
      isComplement = data.match(/^complement\((.*)\)$/);
      strand = 0;
      ranges = [];
      if (!!isComplement) {
        strand = 1;
        data = isComplement[1];
      }
      isJoin = data.match(/^join\((.*)\)$/);
      if (!!isJoin) {
        _ref = isJoin[1].split(',');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          r = _ref[_i];
          parts = (function() {
            var _j, _len1, _ref1, _results;
            _ref1 = r.split('..');
            _results = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              a = _ref1[_j];
              _results.push(parseInt(a) - 1);
            }
            return _results;
          })();
          ranges.push({
            start: parts[0],
            end: parts[1],
            id: id
          });
          id += 1;
        }
      } else {
        parts = (function() {
          var _j, _len1, _ref1, _results;
          _ref1 = data.split('..');
          _results = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            a = _ref1[_j];
            _results.push(parseInt(a) - 1);
          }
          return _results;
        })();
        ranges.push({
          start: parts[0],
          end: parts[1],
          id: id
        });
      }
      console.groupEnd();
      return retval = {
        strand: strand,
        ranges: ranges
      };
    };

    GenBank.prototype.getFeatures = function() {
      var components, currentFeature, data, id, line, p, parts, retval, s, _i, _len, _ref;
      console.groupCollapsed("Getting features");
      if (this.data.features != null) {
        console.debug("We already parsed the features!");
        console.groupEnd();
        return this.data.features;
      }
      retval = [];
      currentFeature = "";
      components = "";
      parts = {};
      id = 0;
      console.groupCollapsed("Looking at each feature");
      _ref = this.data.FEATURES.split(this.newline).slice(1);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (line.trim()[0] !== "/") {
          console.debug("This is the start of a new feature");
          if (currentFeature !== "") {
            console.debug("Storing old feature");
            data = {
              currentFeature: currentFeature,
              location: components,
              parameters: parts,
              id: id
            };
            id += 1;
            retval.push(data);
            parts = {};
          }
          p = line.trim().split(/[ ]+/);
          currentFeature = p[0];
          components = p.slice(1).join(" ");
          components = GenBank.parseLocationData(components);
        } else {
          console.debug("Adding", line);
          s = line.trim().split("=");
          parts[s[0]] = s[1].slice(1, -1);
        }
      }
      console.groupEnd();
      if (parts !== {}) {
        retval.push({
          currentFeature: currentFeature,
          location: components,
          parameters: parts,
          id: id
        });
      }
      console.debug("Here's your features sir!");
      console.groupEnd();
      return this.data.features = retval;
    };

    return GenBank;

  })();

}).call(this);
