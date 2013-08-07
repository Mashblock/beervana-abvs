define ["d3"], (d3)->
  class BubbleGraph
    width: 940
    constructor: (@element, @path)->
      @svg = d3.select(@element).append("svg")
        .attr("width", @width)
      @x_scale = d3.scale.linear()
        .range([0,700])
      d3.csv("data/beervana.csv").get (error, rows)=>
        @x_scale.domain d3.extent(rows, (d)-> parseFloat(d.abv))
        data = d3.nest()
          .key((d)-> d.brewery)
          .entries(rows)
        @redraw(data)

    redraw: (data)->
      @svg.attr("height", data.length*20)

      rows = @svg.selectAll("g.row")
        .data(data, (d)-> d.key)
      new_rows = rows.enter()
        .append("g")
        .attr("class", "row")
      new_rows.append("text")
        .attr("class","brewery-name")
      new_rows.append("g")
        .attr("class", "circles")

      rows.exit().remove()

      rows.attr("transform", (d,i)-> "translate(0,#{i*20})")
      rows.select("text.brewery-name")
        .attr("transform", "translate(200,10)")
        .text((d)-> d.key)
      rows.select("g.circles").attr("transform", "translate(220,0)")

      circles = rows.select("g.circles").selectAll("circle")
        .data ((d)-> d.values), ((d)-> d.beer_name)
      circles.enter()
        .append("circle")
        .append("title")
      circles.exit().remove()
      circles.attr("r", 5)
        .attr("cx", (d)=> @x_scale(d.abv))
        .attr("cy", 10)
      circles.select("title")
        .text((d)-> "#{d.brewery} #{d.beer_name} - #{d.abv}%")
