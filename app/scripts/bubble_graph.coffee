define ["d3", "underscore"], (d3, _)->
  class BubbleGraph
    width: 940
    constructor: (@element, @path)->
      @conditions = {}
      @svg = d3.select(@element).append("svg")
        .attr("width", @width)
      @paper = @svg.append("g")
        .attr("transform", "translate(0,50)")

      @axis_format = d3.format(".1f")

      @svg.append("g")
        .attr("class", 'top_axis')
        .attr("transform", "translate(220,40)")

      @svg.select("g.top_axis").append("text")
        .attr("class","label")
        .attr("transform", "translate(350,-30)")
        .text("Alcohol by volume (ABV)")

      @svg.append("g")
        .attr("class", 'bottom_axis')

      @svg.select("g.bottom_axis").append("text")
        .attr("class","label")
        .attr("transform", "translate(350,35)")
        .text("Alcohol by volume (ABV)")

      @x_scale = d3.scale.linear()
        .range([0,700])

      d3.select("#country")
        .on "change", => @filter {country: d3.event.target.value}
      d3.select("#style")
        .on "change", => @filter {style: d3.event.target.value}

      d3.csv("data/beervana.csv").get (error, rows)=>
        @raw = rows

        @populateCountries(@raw)
        @populateStyles(@raw)
        @redraw(rows)

    populateStyles: (rows=[])->
      styles=_(rows).chain()
        .pluck("style")
        .uniq()
        .compact()
        .sort()
        .map((d)-> [d, d])
        .value()
      styles.unshift(["all", "All Styles"])
      options = d3.select("#style").selectAll("option")
        .data(styles)
        .enter()
        .append("option")
      options.text((d)-> d[1])
        .attr("value", (d)-> d[0])


    populateCountries: (rows=[])->
      countries = _(rows).chain()
        .pluck("country")
        .uniq()
        .sort()
        .map((d)-> [d, d])
        .value()
      countries.unshift(["all", "All Countries"])
      options = d3.select("#country").selectAll("option")
        .data(countries)
        .enter()
        .append("option")
      options.text((d)-> d[1])
        .attr("value", (d)-> d[0])

    filter: (new_conditions={})->
      _(new_conditions).forEach (value, key)=>
        unless value == 'all'
          @conditions[key] = value
        else
          delete @conditions[key]
      rows = unless _(@conditions).isEmpty() then _(@raw).where(@conditions) else @raw
      @redraw(rows)

    redraw: (rows)->
      @x_scale
        .domain(d3.extent(rows, (d)-> parseFloat(d.abv)))
        .nice()
      data = d3.nest()
          .key((d)-> d.brewery)
          .entries(rows)
      height =  data.length*20 + 100
      @svg.attr("height", height)

      if data.length < 2
        @svg.selectAll("text.label").style("visibility","hidden")
      else
        @svg.selectAll("text.label").style("visibility","visible")


      top_axis = d3.svg.axis()
        .scale(@x_scale)
        .orient("top")
        .tickFormat((d)=>@axis_format(d)+"%")

      bottom_axis = d3.svg.axis()
        .scale(@x_scale)
        .orient("bottom")
        .tickFormat((d)=>@axis_format(d)+"%")

      d3.select("g.top_axis").call(top_axis)
      d3.select("g.bottom_axis")
        .attr("transform", "translate(220,#{height-40})")
        .call(bottom_axis)

      rows = @paper.selectAll("g.row")
        .data(data, (d)-> d.key)
      new_rows = rows.enter()
        .append("g")
        .attr("class", "row")

      new_rows.append("text")
        .attr("class","brewery-name")
      new_rows.append("g")
        .attr("class", "circles")

      rows.exit()
        .transition()
        .duration(300)
        .style("opacity", 0)
        .remove()

      rows
        .transition()
        .duration(300)
        .attr("transform", (d,i)-> "translate(0,#{i*20})")
      rows.select("text.brewery-name")
        .text((d)-> d.key)
        .attr("transform", "translate(200,10)")

      rows.select("g.circles").attr("transform", "translate(220,0)")

      circles = rows.select("g.circles").selectAll("circle")
        .data ((d)-> d.values), ((d)-> d.beer_name)
      circles.enter()
        .append("circle")
        .append("title")
      circles.exit().remove()
      circles.attr("r", 5)
        .attr("cy", 10)
        .transition()
        .duration(500)
        .attr("cx", (d)=> @x_scale(d.abv))

      circles.select("title")
        .text((d)-> "#{d.brewery} #{d.beer_name} - #{d.abv}%")
