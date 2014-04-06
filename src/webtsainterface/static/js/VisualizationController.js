/**
 * Created by Juan on 4/6/14.
 */

TsaApplication.VisualizationController = (function (self) {
    self.plottingMethods = { addPlot: {}, newPlot: {} };
    self.plotTypes = { histogram: drawHistogram, multiseries: drawMultiseries, box: drawBoxPlot };
    self.currentPlot = self.plotTypes.multiseries;
    self.plottedSeries = [];

    var plotDataReady = new CustomEvent("plotdataready", { bubbles:true, cancelable:false });
    var plotDataLoading = new CustomEvent("plotdataloading", { bubbles:true, cancelable:false });
    var plotStarted = new CustomEvent("plotstarted", { bubbles:true, cancelable:false });
    var plotFinished = new CustomEvent("plotfinished", { bubbles:true, cancelable:false });

    self.prepareSeries = function(series, method) {
        if (method === self.plottingMethods.addPlot && self.plottedSeries.length >= 5) {
            //TODO: TsaApplication.UiHelper.showMessage('tiene que quitar un series');
            return;
        } else if (method === self.plottingMethods.newPlot) {
            self.plottedSeries.length = 0;
        } //TODO: also check if method is not a plotting method and return.

        var loadedData = 0;
        self.plottedSeries.push(series);
        document.dispatchEvent(plotDataLoading);

        self.plottedSeries.forEach(function(dataseries) {
            dataseries.loadDataset(function() {
                if (++loadedData >= self.plottedSeries.length) {
                    document.dispatchEvent(plotDataReady);
                }
            });
        });
    };

    self.plotSeries = function() {
        if (self.plottedSeries.length === 0) {
            return;
        }

        document.dispatchEvent(plotStarted);

        $("#graphContainer").empty();
        $("#legendContainer").find("ul").empty();

        $("#dpd1").datepicker('setValue', _.min(
            _(self.plottedSeries)
                .pluck('begindatetime')
                .map(function(date){return new Date(date)}))
        );
        $("#dpd2").datepicker('setValue', _.max(
            _(self.plottedSeries)
                .pluck('enddatetime')
                .map(function(date){return new Date(date)}))
        );

        self.currentPlot();
        document.dispatchEvent(plotFinished);
    };

    $(window).resize(_.debounce(function(){
        self.plotSeries();
    }, 500));



    function drawMultiseries() {
        var varnames = _.pluck(self.plottedSeries, 'variablename');
        var data = _(_(self.plottedSeries).pluck('dataset')).flatten();

        // first we need to corerce the data into the right formats
        var parseDate = d3.time.format("%Y-%m-%dT%I:%M:%S").parse;
        var axisMargin = 60;

        var margin = {top: 20, right: 10 + (Math.floor(varnames.length / 2)) * axisMargin, bottom: 60, left: (Math.ceil(varnames.length / 2)) * axisMargin},
            width = $("#graphContainer").width() - margin.left - margin.right,
            height = $("#graphContainer").height() - margin.top - margin.bottom;

        // even: f(n) = n * 10
        // odd: f(n) = width - (n-1) * 10
        var axisProperties = [
            {xTranslate: 0, orient: "left", textdistance: -50},
            {xTranslate: width, orient: "right", textdistance: 50},
            {xTranslate: -65, orient: "left", textdistance: -50},
            {xTranslate: width + 65, orient: "right", textdistance: 50},
            {xTranslate: -130, orient: "left", textdistance: -50}
        ];

        var minDate = new Date(8640000000000000);
        var maxDate = new Date(-8640000000000000);

        for (var i = 0; i < data.length; i++) {
            var parsedDate = parseDate(data[i]['date']);
            if (minDate.valueOf() > parsedDate.valueOf()) {
                minDate = parsedDate;
            }
            if (maxDate.valueOf() < parsedDate.valueOf()) {
                maxDate = parsedDate;
            }
        }

        data = data.map(function (d) {
            return {
                seriesID: +d.seriesID,
                date: parseDate(d['date']),
                val: +d['value'] };
        });

        // Update minimum and maximum dates

        var dateFirst = $('#dpd1').datepicker({
            onRender: function (date) {
                return (date.valueOf() > maxDate.valueOf() || date.valueOf() < minDate.valueOf()) ? 'disabled' : '';
            }
        }).on('changeDate',function (ev) {
            if (ev.date.valueOf() < dateLast.date.valueOf()) {
                var newDate = new Date(ev.date)
                newDate.setDate(newDate.getDate() + 1);
                dateLast.setValue(newDate);
            }
            dateFirst.hide();
            $('#dpd2')[0].focus();
        }).data('datepicker');

        var dateLast = $('#dpd2').datepicker({
            onRender: function (date) {
                return (date.valueOf() > maxDate.valueOf() || date.valueOf() < minDate.valueOf()) ? 'disabled' : '';
            }
        }).on('changeDate',function (ev) {
            dateLast.hide();
        }).data('datepicker');


        var nowTemp = new Date();
        var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);

        // If no dates are set, display the whole thing
        if (dateFirst.date.valueOf() == now.valueOf() && dateLast.date.valueOf() == now.valueOf()) {
            dateFirst.date = minDate;
            dateLast.date = maxDate;
        }

        // Filter by dates if specified
        data = data.filter(function (d) {
            return (d.date.valueOf() >= dateFirst.date.valueOf() && d.date.valueOf() <= dateLast.date.valueOf());
        })

        // then we need to nest the data on seriesID since we want to only draw one
        // line per seriesID
        data = d3.nest().key(function (d) {
            return d.seriesID;
        }).entries(data);

        var x = d3.time.scale()
            .domain([d3.min(data, function (d) {
                return d3.min(d.values, function (d) {
                    return d.date;
                });
            }),
                d3.max(data, function (d) {
                    return d3.max(d.values, function (d) {
                        return d.date;
                    });
                })])
            .range([0, width])
            .nice(d3.time.day);

        var color = d3.scale.category10()
            .domain(d3.keys(data[0]).filter(function (key) {
                return key === "seriesID";
            }));

        var y = new Array(data.length);
        var yAxis = new Array(data.length);
        var lines = new Array(data.length);

        var xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom");

        var svg = d3.select("#graphContainer").append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        svg.append("g")
            .attr("class", "x axis")
            //.attr("width", width  - margin.left - margin.right)
            .attr("transform", "translate(0," + (height) + ")")
            .call(xAxis)
        .append("text")
          .style("text-anchor", "end")
          .attr("x", width/2)
          .attr("y", 35)
          .text("Date");;

        // This loop builds and draws each time series
        for (var i = 0; i < data.length; i++) {
            y[i] = d3.scale.linear()
                .domain([d3.min(data, function (d) {
                    if (d.key == i) {
                        return d3.min(d.values, function (d) {
                            return d.val;
                        });
                    }
                }), d3.max(data, function (d) {
                    if (d.key == i) {
                        return d3.max(d.values, function (d) {
                            return d.val;
                        });
                    }
                })])
                .range([height, 0]);

            yAxis[i] = d3.svg.axis()
                .scale(y[i])
                .orient(axisProperties[i].orient);

            lines[i] = d3.svg.line()
                //.interpolate("basis")
                .x(function (d) {
                    return x(d.date);
                })
                .y(
                function (d) {
                    return y[d.seriesID](d.val);
                });

            svg.append("g")
                .attr("class", "y axis")
                .style("fill", color(i))
                .attr("transform", "translate(" + axisProperties[i].xTranslate + " ,0)")
                .call(yAxis[i])
            .append("text")
             .attr("transform", "rotate(-90)")
             .attr("y", axisProperties[i].textdistance)
             .attr("x", 5)
             .attr("dy", ".71em")
             .style("text-anchor", "end")
             .text("variable");

            $("#legendContainer ul").append(
                '<li class="list-group-item">' +
                    '<input type="checkbox" checked="" data-id="' + i + '">' +
                    '<font color=' + color(i) + ' style="font-size: 22px; line-height: 1;"> ■ '  + '</font>' + varnames[i] +
                    '</li>');
        }

        $('#panel-right input[type="checkbox"]').click(function () {
            var that = this;
            var path = $("#path" + that.getAttribute("data-id"));

            if (that.checked) {
                path.show();
            }
            else {
                path.hide();
            }
        });

        var seriesID = svg.selectAll(".seriesID")
            .data(data, function (d) {
                return d.key;
            })
            .enter().append("g")
            .attr("id", function (d) {
                return "path" + d.key;
            })
            .attr("class", "seriesID");

        seriesID.append("path")
            .attr("class", "line")
            .style("stroke-width", 1.5)
            .on("click", function (d) {
                if(d3.select(this).style("stroke-width") == "2.5px"){
                   d3.select(this)
                    .style("stroke-width", 1.5);
                }
                else{
                    svg.selectAll(".line")
                    .style("stroke-width", 1.5)
                    d3.select(this)
                    .style("stroke-width", 2.5);
                }
                this.parentNode.parentNode.appendChild(this.parentNode);
            })

            .attr("d", function (d) {
                return lines[d.key](d.values);
            })
            .style("stroke", function (d) {
                return color(d.key);
            }
        );
    }

    function drawHistogram() {
        /* Initialize Histogram*/
        var varnames = _.pluck(self.plottedSeries, 'variablename');
        var values = _(_(self.plottedSeries).pluck('dataset')).map(function(dataset) {
            return _.pluck(dataset, 'value');
        });

        var minHeight = 15;                 // minimum height in pixels of a rectangle
        var textHeight = -8;                 // distance in pixels for the text from the top of the rectangle
        var numOfDatasets = values.length;
        var numOfTicks = 20;                // Number of divisions for columns
        var colors = d3.scale.category10();

        var margin = {top: 10, right: 30, bottom: 60, left: 80},
            width = $("#graphContainer").width() - margin.left - margin.right,
            height = $("#graphContainer").height() - margin.bottom - margin.top;

        // A formatter for counts.

        for (var i = 0; i < numOfDatasets; i++) {
            var formatCount = d3.format(",.0f");
            var graphHeight = $("#graphContainer").height() / numOfDatasets - margin.bottom;
            var domainMin = Math.min.apply(Math, values[i]);
            var domainMax = Math.max.apply(Math, values[i]);

             $("#legendContainer ul").append(
            '<li class="list-group-item">' +
                '<font color=' + colors(i) + ' style="font-size: 22px; line-height: 1;"> ■ '  + '</font>' + varnames[i] +
                '</li>');

            var x = d3.scale.linear()
                .domain([domainMin, domainMax])
                .range([0, width]);

            // Generate a histogram using uniformly-spaced bins.
            var data = d3.layout.histogram()
                .bins(x.ticks(numOfTicks))
                (values[i]);

            var y = d3.scale.linear()
                .domain([0, d3.max(data, function (d) {return d.y;})])
                .range([graphHeight, 0]);

            var xAxis = d3.svg.axis()
                .scale(x)
                .orient("bottom");

            var yAxis = d3.svg.axis()
                .ticks(25 / numOfDatasets)
                //.tickSize(-width, 0, 0)
                //.orient("right")
                .scale(y)
                .orient("left");

            var svg = d3.select("#graphContainer").append("svg")
                .attr("width", width + margin.left + margin.right)
                .attr("height", graphHeight + margin.bottom)
                .append("g")
                .attr("transform", "translate(" + margin.left + ",0)");

            var bar = svg.selectAll(".bar")
                .data(data)
                .enter().append("g")
                .attr("class", "bar")
                .attr("transform", function (d) {
                    return "translate(" + x(d.x) + "," + y(d.y) + ")";
                })
                .on("mouseover", function (d) {
                   d3.select(this).append("text")
                    .attr("dy", ".75em")
                    .attr("y", 0)
                    .attr("x", x(data[0].dx + domainMin) / 2)
                    .attr("text-anchor", "middle")
                    .text(function (d) {
                        return formatCount(d.y);
                    });
                })
                .on("mouseout", function (d) {
                   d3.select(this).select("text").remove();
                });

            bar.append("rect")
                .attr("x", 1)
                .attr("width", x(data[0].dx + domainMin) - 1)
                .style("fill", colors(i))

                .style("opacity", 1)
                .attr("height", function (d) {
                        return graphHeight - y(d.y);
                });

            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + graphHeight + ")")
                .call(xAxis)
                .append("text")
                .attr("class", "x label")
                  .attr("x", width / 2)
                  .attr("y", margin.bottom - 25)
                  .style("text-anchor", "end")
                  .text("VarName (Unit)");


            svg.append("g")
              .attr("class", "y axis")
              .call(yAxis)
            .append("text")
              .attr("transform", "rotate(-90)")
              .attr("y", 14)
              .style("text-anchor", "end")
              .text("Y Label");
        }
    }

    function drawBoxPlot(){
        var varnames = _.pluck(self.plottedSeries, 'variablename');
        var observations = _(_(self.plottedSeries).pluck('dataset')).map(function(dataset) {
            return _.pluck(dataset, 'value');
        });

        var colors = d3.scale.category10();
        for (var i = 0; i < observations.length; i++){

            var margin = {top: 10, right: 50, bottom: 20, left: 50},
            width = 120  - margin.left - margin.right,
            height = 500  - margin.top - margin.bottom;

             $("#legendContainer ul").append(
            '<li class="list-group-item"><label class="checkbox">' +
                '<font color=' + colors(i) + ' style="font-size: 22px; line-height: 1;"> ■ '  + '</font>' + varnames[i] +
                '</label></li>');

            var data = [];
            data[0] = observations[i];
            var min = Infinity,
                max = -Infinity;

            for (var j = 0; j < data[0].length; j++){
                data[0][j] = parseFloat(data[0][j]);
                if(data[0][j] > max){
                    max = data[0][j];
                }
                if (data[0][j] < min){
                    min = data[0][j]
                }
            }

            var chart = d3.box()
                .whiskers(iqr(1.5))
                .width(width)
                .height(height);

            chart.domain([min, max]);

              var svg = d3.select("#graphContainer").selectAll("svg")
                  .data(data)
                .enter().append("svg")
                  .attr("class", "box")
                  .attr("width", width + margin.left + margin.right)
                  .attr("height", height + margin.bottom + margin.top)
                .append("g")
                  .attr("transform", "translate(" + (margin.left + i * width) + "," + margin.top + ")")
                  .call(chart);
         }

        // Returns a function to compute the interquartile range.
        function iqr(k) {
          return function(d, i) {
            var q1 = d.quartiles[0],
                q3 = d.quartiles[2],
                iqr = (q3 - q1) * k,
                i = -1,
                j = d.length;
            while (d[++i] < q1 - iqr);
            while (d[--j] > q3 + iqr);
            return [i, j];
          };
        }
    }

	return self;
}(TsaApplication.VisualizationController || {}));