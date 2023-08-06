local function get_next_line_index(entity)
    return entity.request_slot_count + 1
end

local function get_items_not_requested(game, entity)
    local items_not_requested = {}

    -- Create a set of all item names
    local all_items = {}
    for item_name, item in pairs(game.item_prototypes) do
        all_items[item_name] = item
    end

    -- Loop over logistic request slots
    for slot = 1, entity.request_slot_count, 1 do
        local request = entity.get_request_slot(slot)
        if request then
            -- game.print("4. Found item in inventory " .. serpent.line(request))
            all_items[request.name] = nil
        end
    end
    -- Add the remaining items to the items_not_requested set
    for _, item in pairs(all_items) do
        if item ~= nil then
            table.insert(items_not_requested, item)
        end
    end

    return items_not_requested
end

local function add_not_requested_items(game, entity, items_not_requested, next_line_index)
    local num_items_not_requested = #items_not_requested
    -- game.print("1. Processing spidertron with next line index " .. next_line_index)
    game.print("Found spidertron with num_items_not_requested " .. num_items_not_requested)
    
    if num_items_not_requested == 0 then
        return false
    end

    local slot = next_line_index
    for _, item in pairs(items_not_requested) do
    -- for slot = next_line_index, next_line_index + num_items_not_requested, 1 do
        if item == nil then
            -- game.print("5. NO ITEM FOUND FOR " .. slot)
            goto continue
        end
        -- game.print("3. Setting " .. slot .. " to " .. item.name)
        entity.set_vehicle_logistic_slot(slot, {name=item.name, min = 0, max = 0})
        slot = slot + 1
        ::continue::
    end
    game.print("Updated slots [" .. next_line_index .. ", " .. slot - 1 .. "]")
end


script.on_event(defines.events.on_entity_damaged,
    function(event)
        local entity = event.entity
        if entity.name == "spidertron" then
            -- local cause = event.cause
            -- if cause and cause.name == "player" then
                -- TODO: What is idiomatic lua to avoid this
            local next_line_index = get_next_line_index(entity)
            local items_not_requested = get_items_not_requested(game, entity)
            add_not_requested_items(game, entity, items_not_requested, next_line_index)
            -- game.print("Items not requested before: " .. serpent.line(items_not_requested))
            -- game.print("Items not requested after: " .. serpent.line(get_items_not_requested(game, entity)))
            -- end
        end
    end
)

