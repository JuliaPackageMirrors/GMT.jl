GMT.jl
======

Julia wrapper for the Generic Mapping Tools [GMT](http://gmt.soest.hawaii.edu)

There is no manual yet but looking into the tests.jl should give a (good) idea on how it works. Note also that this
wrapper works only with the GMT5.2.1. The developing version suffered too many changes and won't work with this wrapper anymore. A new version of this wrapper will be released parallel to GMT5.3 (by end of September).

Install
=======

    (Pkg.init()		# If you haven't done it yet)
    Pkg.add("GMT")

On OSX, with a manual GMT build and dependencies obtained with Homebrew (that are installed at /user/local/lib), I had to help
Julia finding MY *libgmt.dylib*, with (this line should than be added to the ~/.juliarc.jl file)

    push!(Libdl.DL_LOAD_PATH, "/Users/j/programs/gmt5/lib")

Using
=====

The Julia wrapper was designed to work in a way the closest as possible to the command line version and yet to provide all the facilities of the Julia language. In this sense, all **GMT** options are put in a single text string that is passed, plus the data itself when it applies, to the ``gmt()`` command. For example to reproduce the CookBook example of an Hemisphere map using a Azimuthal projection

    gmt("pscoast -Rg -JA280/30/3.5i -Bg -Dc -A1000 -Gnavy -P > GMT_lambert_az_hemi.ps")

but that is not particularly interesting as after all we could do the exact same thing on the a shell command line. Things start to get interesting when we can send data *in* and *out* from Julia to
**GMT**. So, consider the following example

    t = rand(100,3) * 150;
    G = gmt("surface -R0/150/0/150 -I1", t);

Here we just created a random data *100x3* matrix and told **GMT** to grid it using it's program *surface*. Note how the syntax follows closely the standard usage but we sent the data to be interpolated (the *t* matrix) as the second argument to the ``gmt()`` function. And on return we got the *G* variable that is a type holding the grid and it's metadata. See the :ref:`grid struct <grid-struct>` for the details of its members.

Imagining that we want to plot that random data art, we can do it with a call to *grdimage*, like

    gmt("grdimage -JX8c -Ba -P -Cblue,red > crap_img.ps", G)

Note that we now sent the *G grid* as argument instead of the **-G** *gridname* that we would have used in the command line. But for readability we could well had left the **-G** option in command string. E.g:

    gmt("grdimage -JX8c -Ba -P -Cblue,red -G > crap_img.ps", G)

While for this particular case it makes no difference to use or not the **-G**, because there is **only** one input, the same does not hold true when we have more than one. For example, we can run the same example but compute the color palette separately.

    cpt = gmt("grd2cpt -Cblue,red", G);
    gmt("grdimage -JX8c -Ba -P -C -G > crap_img.ps", cpt, G)

Now we had to explicitly write the **-C** & **-G** (well, actually we could have omitted the **-G** because it's a mandatory input but that would make the things more confusing). Note also the order of the input data variables. It is crucial that they are used in the **exact** same order as the options in the command string.

To illustrate another aspect on the importance of the order of input data let us see how to plot a sinus curve made of colored filled circles.

    x = linspace(-pi, pi)';            # The xx var
    seno = sin(x);                     # yy
    xyz  = [x seno seno];              # Duplicate yy so that it can be colored
    cpt  = gmt("makecpt -T-1/1/0.1");  # Create a color palette
    gmt("psxy -R-3.2/3.2/-1.1/1.1 -JX12c -Sc0.1c -C -P -Ba > seno.ps", cpt, xyz)

The point here is that we had to give *cpt, xyz* and not *xyz, cpt* (which would error) because input data associated with an option letter **always comes first** and has to respect the corresponding options order in command string.

To plot text strings we send in the input data wrapped in a cell array. Example:

    lines = Any["5 6 Some label", "6 7 Another label"];
    gmt("pstext -R0/10/0/10 -JM6i -Bafg -F+f18p -P > text.ps", lines)

and we get back text info in cell arrays as well. Using the *G* grid computed above we can run *gmtinfo* on it

    info = gmt("gmtinfo", G)

But since GMT is build with GDAL support we can make good use of if to read and plot images that don't even need to be stored
locally. In the following example we will load a network image (GDAL will do that for us) and make a *creative* world map.
Last command is used to convert the PostScript file into a transparent PNG.

    gmt("grdimage -Rd -JI15c -Dr http://larryfire.files.wordpress.com/2009/07/untooned_jessicarabbit.jpg -P -Xc -Bg -K > jessy.ps")
    gmt("pscoast -R -J -W1,white -Dc -O >> jessy.ps")
    gmt("psconvert jessy.ps -TG -A")

![Screenshot](http://w3.ualg.pt/~jluis/jessy.png)

At the end of an **GMT** session work we call the internal functions that will do the house keeping of freeing no longer needed memory. We do that with this command:

    gmt("destroy")

So that's basically how it works. When numeric data has to be sent *in* to **GMT** we use Julia variables holding the data in matrices or structures or cell arrays depending on the case. On return we get the computed result stored in variables that we gave as output arguments. Things only complicate a little more for the cases where we can have more than one *input* or *output* arguments. The file *gallery.jl*, that reproduces the examples in the Gallery section of the GMT documentation, has many (not so trivial) examples on usage of the **GMT** wrapper.

----------

The Grid type
-------------

    type GMTJL_GRID 	# The type holding a local header and data of a GMT grid
	   ProjectionRefPROJ4::ASCIIString    # Projection string in PROJ4 syntax (Optional)
	   ProjectionRefWKT::ASCIIString      # Projection string in WKT syntax (Optional)
	   range::Array{Float64,1}            # 1x6 vector with [x_min x_max y_min y_max z_min z_max]
	   inc::Array{Float64,1}              # 1x2 vector with [x_inc y_inc]
	   n_rows::Int                        # Number of rows in grid
	   n_columns::Int                     # Number of columns in grid
	   n_bands::Int                       # Not-yet used (always == 1)
	   registration::Int                  # Registration type: 0 -> Grid registration; 1 -> Pixel registration
	   NoDataValue::Float64               # The value of nodata
	   title::ASCIIString                 # Title (Optional)
	   remark::ASCIIString                # Remark (Optional)
	   command::ASCIIString               # Command used to create the grid (Optional)
	   DataType::ASCIIString              # 'float' or 'double'
	   x::Array{Float64,1}                # [1 x n_columns] vector with XX coordinates
	   y::Array{Float64,1}                # [1 x n_rows]    vector with YY coordinates
	   z::Array{Float32,2}                # [n_rows x n_columns] grid array
	   x_units::ASCIIString               # Units of XX axis (Optional)
	   y_units::ASCIIString               # Units of YY axis (Optional)
	   z_units::ASCIIString               # Units of ZZ axis (Optional)
    end

The Image type
--------------

    type GMTJL_IMAGE     # The type holding a local header and data of a GMT image
       ProjectionRefPROJ4::ASCIIString    # Projection string in PROJ4 syntax (Optional)
       ProjectionRefWKT::ASCIIString      # Projection string in WKT syntax (Optional)
       range::Array{Float64,1}            # 1x6 vector with [x_min x_max y_min y_max z_min z_max]
       inc::Array{Float64,1}              # 1x2 vector with [x_inc y_inc]
       n_rows::Int                        # Number of rows in image
       n_columns::Int                     # Number of columns in image
       n_bands::Int                       # Number of bands in image
       registration::Int                  # Registration type: 0 -> Grid registration; 1 -> Pixel registration
       NoDataValue::Float64               # The value of nodata
       title::ASCIIString                 # Title (Optional)
       remark::ASCIIString                # Remark (Optional)
       command::ASCIIString               # Command used to create the image (Optional)
       DataType::ASCIIString              # 'uint8' or 'int8' (needs checking)
       x::Array{Float64,1}                # [1 x n_columns] vector with XX coordinates
       y::Array{Float64,1}                # [1 x n_rows]    vector with YY coordinates
       image::Array{UInt8,3}              # [n_rows x n_columns x n_bands] image array
       x_units::ASCIIString               # Units of XX axis (Optional)
       y_units::ASCIIString               # Units of YY axis (Optional)
       z_units::ASCIIString               # Units of ZZ axis (Optional) ==> MAKES NO SENSE
       colormap::Array{Clong,1}           # 
       alpha::Array{UInt8,2}              # A [n_rows x n_columns] alpha array
    end

The CPT type
------------

    type GMTJL_CPT
        colormap::Array{Float64,2}
        alpha::Array{Float64,1}
        range::Array{Float64,2}
        rangeMinMax::Array{Float64,1}
    end
