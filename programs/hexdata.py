# By Pytel

import numpy as np
from my_colors import *

class HexData():
    def __init__(self, file_name, radix : np.uint32 = 16):
        self.file_name = file_name
        self.radix = radix
        self.data = self.load_data()

    def load_data(self) -> np.array:
        """
        load data from file, data is dipendeing on file format and radix.
        """
        if self.file_name.split('.')[-1] == "txt":
            return self.load_data_from_txt()
        else:
            raise Exception(Red + "Unsupported file format!" + NC)
        
    def load_data_from_txt(self) -> np.array:
        """
        load data from txt file, data is dipendeing on radix.
        """
        if self.radix == 16:
            return self.load_data_from_txt_hex()
        elif self.radix == 10:
            return self.load_data_from_txt_dec()
        elif self.radix == 2:
            raise NotImplementedError(Yellow + "Not implemented yet!" + NC)
        else:
            raise Exception(Red + "Unsupported radix!" + NC)
        
    def load_data_from_txt_hex(self) -> np.array:
        """
        load data from txt file, data have hexa radix.
        Each line is one hexa number 32 bit long.
        """
        data = np.loadtxt(self.file_name, dtype=np.uint32, delimiter='\n', comments='#')
        return data

    def __str__(self) -> str:
        return self.data