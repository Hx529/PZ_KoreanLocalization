-- Leer todas las revistas seleccionadas
ReadAllBooks = {}

function ReadAllBooks.readAll(playerIndex, context, items)
    -- print("Bandolero: Menu contextual para leer todo creado.")
    local books = {}
    local player = getSpecificPlayer(playerIndex)

    -- Verifica que el jugador existe
    if player then
        -- print("Jugador encontrado: " .. player:getDisplayName())
    else
        -- print("Error: Jugador no encontrado.")
        return
    end

    -- Recorre los items seleccionados (solo los seleccionados)
    for i = 1, #items do
        local item = items[i].items and items[i].items[1] or items[i]
        -- print("Item seleccionado: " .. item:getName())

        if item:getCategory() == "Literature" then  -- Si es una revista o libro
            -- print("Es literatura: " .. item:getName())
            local container = item:getContainer() or items[i].container
            table.insert(books, {book = item, container = container}) -- Añade libro con su contenedor
        else
            -- print(item:getName() .. " no es literatura.")
        end
    end

    -- Añade la opción al menú si hay libros/revistas
    if #books > 0 then
        -- print("Revistas/Libros encontrados: " .. #books)
        context:addOption(getText("ContextMenu_ReadAll"), books, ReadAllBooks.readBooks, player)
    else
        -- print("No se encontraron revistas/libros.")
    end
end

-- Función para leer cada revista/libro
function ReadAllBooks.readBooks(books, player)
    -- print("Leyendo todas las revistas/libros seleccionados.")

    if not player then
        -- print("Error: El jugador es nil.")
        return
    end

    local readBooks = {} -- Lista para almacenar los libros leídos

    local function readNextBook(index)
        if index > #books then
            -- print("Todos los libros han sido leídos.")
            returnBooksToContainer(player, readBooks) -- Devuelve todos los libros al contenedor
            return
        end

        local bookData = books[index]
        local book = bookData.book
        local container = bookData.container

        if book then
            -- print("Intentando retirar el libro o revista del contenedor..")
            if container and container:contains(book) then
                local inventory = player:getInventory()
                inventory:AddItem(book)  -- Agrega el libro al inventario

                -- print("Libro " .. book:getName() .. " retirado del contenedor y agregado al inventario del jugador.")

                -- Comprueba si el libro ahora está en el inventario del jugador
                if player:getInventory():contains(book) then
                    -- print("Leyendo revista/libro: " .. book:getName())

                    -- Crea la acción de lectura
                    local readingTime = determineReadingTime(book)
                    local action = ISReadABook:new(player, book, readingTime)

                    -- Callback después de completar la lectura
                    function action:perform()
                        ISReadABook.perform(self)
                        table.insert(readBooks, book)  -- Almacena el libro leído
                        readNextBook(index + 1)  -- Pasa al siguiente libro
                    end

                    ISTimedActionQueue.add(action)  -- Agrega la acción a la cola
                else
                    -- print("Error: El libro " .. book:getName() .. " no está en el inventario del jugador después de retirarlo del contenedor.")
                end
            else
                -- print("Error: El libro " .. book:getName() .. " no se encuentra en el contenedor.")
            end
        else
            -- print("Error: El libro en la posición " .. index .. " es nil.")
        end
    end

    -- Inicia el proceso de lectura con el primer libro
    readNextBook(1)
end

-- Función para determinar el tiempo de lectura
function determineReadingTime(book)
    local readingTime
    if book:getNumberOfPages() == -1 then
        local taughtRecipes = book:getTeachedRecipes()
        if type(taughtRecipes) == "table" then
            readingTime = 50000 * #taughtRecipes -- Tiempo base de 1000 ms por receta
            -- print("Es una revista. Tiempo de lectura calculado en función de recetas: " .. readingTime)
        else
            readingTime = 50000  -- Tiempo base por defecto si no hay recetas
            -- print("Es una revista sin recetas. Tiempo de lectura predeterminado: " .. readingTime)
        end
    else
        readingTime = math.max(book:getNumberOfPages() * 5, 5000)
        -- print("ReadingTime para libro => " .. readingTime)
    end
    return readingTime
end

-- Función para devolver todos los libros leídos al contenedor
function returnBooksToContainer(player, readBooks)
    if not player or #readBooks == 0 then
        -- print("Error: Parámetros inválidos para devolver libros.")
        return
    end

    local inventory = player:getInventory()

    for _, book in ipairs(readBooks) do
        if inventory:contains(book) then
            inventory:Remove(book) -- Elimina el libro del inventario del jugador
            -- Suponemos que el contenedor del libro se obtiene de otro modo o se pasa como parámetro
            local container = book:getContainer()
            if container then
                container:addItem(book) -- Devuelve el libro al contenedor
                -- print("Libro devuelto a la estantería: " .. book:getName())
            else
                -- print("Error: No se pudo encontrar el contenedor para " .. book:getName())
            end
        else
            -- print("Error: El libro " .. book:getName() .. " no se encuentra en el inventario del jugador.")
        end
    end
end

-- Vincula la función al menú contextual
Events.OnFillInventoryObjectContextMenu.Add(ReadAllBooks.readAll)
