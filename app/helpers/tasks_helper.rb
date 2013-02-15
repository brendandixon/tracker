module TasksHelper

  def points_to_class(points)
    case points
    when 0, nil then 'zero-points'
    when 1 then 'one-point'
    when 2 then 'two-points'
    when 3 then 'three-points'
    when 5 then 'five-points'
    when 8 then 'eight-points'
    end
  end

end
