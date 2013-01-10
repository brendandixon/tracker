module Constants

  N_BYTES = [0].pack('i').size
  N_BITS = N_BYTES * 8
  
  INTEGER_MAX = 2 ** (N_BITS - 2) - 1
  INTEGER_MIN = -INTEGER_MAX - 1

end
