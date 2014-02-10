require 'ffi'

module FFIUtils

  SIZEOF_INT = [1.to_i].pack('i').size
  SIZEOF_FLOAT = [1.to_f].pack('f').size

  def strarr array
    strptrs = []
    array.each do |str|
      strptrs << FFI::MemoryPointer.from_string(str)
    end

    argv = FFI::MemoryPointer.new :pointer, strptrs.length
    strptrs.each_with_index do |p, i|
     argv[i].put_pointer 0, p
    end

    argv
  end

  def f_arr array
    argv = FFI::MemoryPointer.new(:float, array.length)
    argv.write_array_of_float array
  end

  def i_arr array
    argv = FFI::MemoryPointer.new(:uint, array.length)
    argv.write_array_of_uint array
  end
end
