do ->
    class Field
        constructor: (@parent, @element, @x, @y, @value = false) ->
            @item = $('<span class="playfield-item"/>')
            @element.empty().append @item
            
            @set()
        update: (chain = false, label) ->
            @item.removeClass (type.class for type in @parent.types).join " "

            type = @parent.types[@value]
            @item.addClass type.class
            if location.hash.match /debug/
                @item.text label or ''
            @element.toggleClass "playfield-chain", chain
        set: (value = false) ->
            if value isnt false
                @value = value
            else
                @value = ~~(Math.random() * 123456)

            @value = @value % @parent.types.length
            @element.data 'value', @value
    
    class Playfield
        constructor: (selector, @types, @width = 10, @height = 8) ->
            @field = {}

            table = $('<table class="playfield"/>')
            for y in [1..@height]
                row = $('<tr/>')
                @field[y] = {}
                for x in [1..@width]
                    td = $('<td class="playfield-field"/>')
                    field = new Field @, td, x, y
                    @field[y][x] = field
                    td.data 'x', x
                    td.data 'y', y
                    row.append td
                table.append row
            $(selector).append table
            
            @display()
        randomize: ->
            for y in [1..@height]
                for x in [1..@width]
                    @field[y][x].set()
            @
        set: (x, y, value) ->
            @field[y][x].set value
            @
        display: ->
            chained = {}
            for y in [1..@height]
                chained[y] = {}
                for x in [1..@width]
                    chained[y][x] = 0

            # test vertical
            for x in [1..@width]
                for y in [1..@height]
                    continue if --chain >= 1

                    value = @field[y][x].value
                    chain = 1
                    chain += 1 while (y + chain <= @height) and (@field[y + chain][x].value == value)
                    if chain >= 3
                        for i in [0..chain - 1]
                            chained[y + i][x] += chain


            # test vertical
            for y in [1..@height]
                for x in [1..@width]
                    continue if --chain >= 1

                    value = @field[y][x].value
                    chain = 1
                    chain += 1 while (x + chain <= @width) and (@field[y][x + chain].value == value)
                    if chain >= 3
                        for i in [0..chain - 1]
                            chained[y][x + i] += chain

            for y in [1..@height]
                for x in [1..@width]
                    @field[y][x].update chained[y][x] > 0, chained[y][x]

            @

    $.getJSON 'types.json', (types) ->
        field = new Playfield "#field", types

        $('.playfield-field').on 'click', ->
            data = $(this).data()
            field.set data.x, data.y, data.value + 1
            field.display()

        $('#randomize').on 'click', ->
            field.randomize().display()
