module GMT

export
	GMT_Call_Module,
	GMT_Create_Session,
	GMT_Create_Data,
	GMT_Get_Default,
	GMT_Option,
	GMT_Read_Data,
	GMT_Register_IO,
	GMT_Get_Data,
	GMT_Read_Data,
	GMT_Retrieve_Data,
	GMT_Retrieve_Data,
	GMT_Message,
	GMT_Call_Module,
	GMT_IS_DATASET, GMT_IS_TEXTSET, GMT_IS_GRID, GMT_IS_LINE,
	GMT_IS_CPT, GMT_IS_IMAGE, GMT_IS_VECTOR, GMT_IS_MATRIX,
	GMT_IS_COORD, GMT_IS_POINT,	GMT_IS_MATRIX, GMT_IS_SURFACE,
	GMT_DATASET,
	GMT_GRID, GMT_MATRIX,
	GMT_UNIVECTOR,
	GMT_IN, GMT_OUT,
	GMT_IS_FILE, GMT_IS_STREAM,	GMT_IS_FDESC,
	GMT_IS_DUPLICATE, GMT_IS_REFERENCE,
	GMT_VIA_NONE, GMT_VIA_VECTOR, GMT_VIA_MATRIX, GMT_VIA_OUTPUT,
	GMT_IS_DUPLICATE_VIA_VECTOR, GMT_IS_REFERENCE_VIA_VECTOR,
	GMT_IS_DUPLICATE_VIA_MATRIX, GMT_IS_REFERENCE_VIA_MATRIX,
	GMT_MODULE_EXIST, GMT_MODULE_PURPOSE, GMT_MODULE_OPT, GMT_MODULE_CMD,
	GMT_GRID_ALL

include("libgmt_h.jl")
include("libgmt.jl")

end # module
