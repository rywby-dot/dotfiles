return {
	setup = function()
		ps.sub("cd", function()
			local cwd = cx.active.current.cwd
			local path = tostring(cwd)

			-- Правила: фрагмент пути = параметры
			local rules = {
				["Downloads"] = { "size", rev = true },
				["Movies"] = { "size", rev = true },
			}

			local target = { "alphabetical", rev = false } -- Дефолт
			for pattern, args in pairs(rules) do
				if string.find(path, pattern) then
					target = args
					break
				end
			end

			-- Применяем только если текущая сортировка отличается
			-- (чтобы не спамить командами при каждом движении)
			ya.manager_emit("sort", {
				target[1],
				reverse = target.rev,
				dir_first = true,
			})
		end)
	end,
}
