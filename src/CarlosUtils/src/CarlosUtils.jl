"""
ax = axisWidthChange(factor; lock="c", ax=nothing)

Changes the width of the current axes by a scalar factor.

= PARAMETERS:
 - factor      The scalar value by which to change the width, for example
               0.8 (to make them thinner) or 1.5 (to make them fatter)

= OPTIONAL PARAMETERS:
 - lock="c"    Which part of the axis to keep fixed. "c", the default does
               the changes around the middle; "l" means keep the left edge fixed
               "r" means keep the right edge fixed

 - ax = nothing   If left as the default (nothing), works on the current axis;
               otherwise should be an axis object to be modified.
"""
function axisWidthChange(factor; lock="c", ax=nothing)
    if ax==nothing; ax=gca(); end
    x, y, w, h = ax.get_position().bounds

    if lock=="l";
    elseif lock=="c" || lock=="m"; x = x + w*(1-factor)/2;
    elseif lock=="r"; x = x + w*(1-factor);
    else error("I don't know lock type ", lock)
    end

    w = w*factor;
    ax.set_position([x, y, w, h])

    return ax
end


"""
ax = axisHeightChange(factor; lock="c", ax=nothing)

Changes the height of the current axes by a scalar factor.

= PARAMETERS:
 - factor      The scalar value by which to change the height, for example
               0.8 (to make them shorter) or 1.5 (to make them taller)

= OPTIONAL PARAMETERS:
 - lock="c"    Which part of the axis to keep fixed. "c", the default does
               the changes around the middle; "b" means keep the bottom edge fixed
               "t" means keep the top edge fixed

 - ax = nothing   If left as the default (nothing), works on the current axis;
               otherwise should be an axis object to be modified.
"""
function axisHeightChange(factor; lock="c", ax=nothing)
    if ax==nothing; ax=gca(); end
    x, y, w, h = ax.get_position().bounds

    if lock=="b";
    elseif lock=="c" || lock=="m"; y = y + h*(1-factor)/2;
    elseif lock=="t"; y = y + h*(1-factor);
    else error("I don't know lock type ", lock)
    end

    h = h*factor;
    ax.set_position([x, y, w, h])

    return ax
end


"""
   ax = axisMove(xd, yd; ax=nothing)

Move an axis within a figure.

= PARAMETERS:
- xd      How much to move horizontally. Units are scaled figure units, from
           0 to 1 (with 1 meaning the full width of the figure)

- yd      How much to move vertically. Units are scaled figure units, from
            0 to 1 (with 1 meaning the full height of the figure)

= OPTIONAL PARAMETERS:
 - ax = nothing   If left as the default (nothing), works on the current axis;
               otherwise should be an axis object to be modified.

"""
function axisMove(xd, yd; ax=nothing)
    if ax==nothing; ax=gca(); end
    x, y, w, h = ax.get_position().bounds

    x += xd
    y += yd

    ax.set_position([x, y, w, h])
    return ax
end
