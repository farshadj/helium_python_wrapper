from cpython cimport PyObject, Py_INCREF
from cpython.pycapsule cimport *
from ctypes import *
from cpython cimport Py_buffer
from libc.stdlib cimport malloc, free
from libc.string cimport *
from libc.stdio cimport *
from cpython.buffer cimport *
# Import the Python-level symbols of numpy

# 
cimport che
import sys


HE_VERSION_MAJOR=2
HE_VERSION_MINOR=8
HE_VERSION_PATCH=2

HE_MAX_DATASTORES=4095
HE_MAX_KEY_LEN=65535
HE_MAX_VAL_LEN=16777215

HE_O_CREATE=1
HE_O_TRUNCATE=2
HE_O_VOLUME_CREATE=4
HE_O_VOLUME_TRUNCATE=8
HE_O_VOLUME_NOTRIM=16
HE_O_NOSORT=32
HE_O_SCAN=64
HE_O_CLEAN=128
HE_O_COMPRESS=256

HE_ERR_SOFTWARE=-100
HE_ERR_ARGUMENTS=-101
HE_ERR_MEMORY=-102
HE_ERR_CHECKSUM=-103
HE_ERR_TERMINATED=-104
HE_ERR_UNSUPPORTED=-105
HE_ERR_DEVICE_STAT=-106
HE_ERR_DEVICE_OPEN=-107
HE_ERR_DEVICE_ACCESS=-108
HE_ERR_DEVICE_LOCK=-109
HE_ERR_DEVICE_GEOMETRY=-110
HE_ERR_DEVICE_READ=-111
HE_ERR_DEVICE_WRITE=-112
HE_ERR_VOLUME_TOO_SMALL=-113
HE_ERR_VOLUME_INVALID=-114
HE_ERR_VOLUME_CORRUPT=-115
HE_ERR_VOLUME_IN_USE=-116
HE_ERR_VOLUME_FULL=-117
HE_ERR_DATASTORE_NOT_FOUND=-118
HE_ERR_DATASTORE_EXISTS=-119
HE_ERR_DATASTORE_IN_USE=-120
HE_ERR_ITEM_NOT_FOUND=-121
HE_ERR_ITEM_EXISTS=-122
HE_ERR_NETWORK_LISTEN=-123
HE_ERR_NETWORK_ACCEPT=-124
HE_ERR_NETWORK_CONNECT=-125
HE_ERR_NETWORK_READ=-126
HE_ERR_NETWORK_WRITE=-127
HE_ERR_NETWORK_PROTOCOL=-128




cdef  che.he_item get_che_he_item(item):
    """The function takes python input item and creates corresponding buffers and return 
       he_item object.
    """
    cdef che.he_item _he_item
     
    cdef Py_buffer val_buf
    cdef Py_buffer key_buf
      
    if (PyObject_CheckBuffer(item.key)):
        output_key=PyObject_GetBuffer(item.key, &key_buf,PyBUF_WRITABLE)

    else:
        raise
      
    if (PyObject_CheckBuffer(item.val)):
        output_val=PyObject_GetBuffer(item.val,&val_buf,PyBUF_WRITABLE)

    else:
        raise
  
  
    _he_item.key = key_buf.buf
    _he_item.key_len = <size_t> item.key_len
    _he_item.val = val_buf.buf
    _he_item.val_len =<size_t> item.val_len
  
    return  _he_item


class he_item:
    """
        The interface class equivelent to he.he_item strucure.
        
    """ 
    def __init__(self):
        self.key_len=0
        self.key=bytearray()
        self.val=bytearray()
        self.val_len=0
        pass

    def set_value(self,key,key_len,val,val_len):
        self.key=key
        self.key_len=key_len
        self.val=val
        self.val_len=val_len
     

ctypedef che.he_env he_env

# Destructor for cleaning up Point objects
cdef del_handler(object obj):
    pass



def he_is_valid(he):
    """
        helium he_is_valid function
    """
    handler=<const che.he_t> PyCapsule_GetPointer(he,'handler')
    return <int> che.he_is_valid(handler)


def he_is_transaction(he):
    """
        helium he_is_transaction function
    """
    handler=<const che.he_t> PyCapsule_GetPointer(he,'handler')
    return <int> che.he_is_transaction(handler)

#  
# def he_enumerate(url,cbf, arg):
#     """
#         helium he_enumerate function
#      
#     """
#  
#     py_byte_url = url.encode('UTF-8')
#     return <int> che.he_enumerate(<const char*> url, <che.he_enumerate_cbf_t> cbf, <void *> arg)

    

# he_open handler to helium 
def he_open(url,name, flags,env):
    """
         helium he_open function
        
    """
    py_byte_url = url.encode('UTF-8')
    py_byte_name = name.encode('UTF-8')
    handler= che.he_open(<const char*> py_byte_url,<const char*> py_byte_name,<int> flags, <const he_env *> env)
    return PyCapsule_New(handler,'handler',<PyCapsule_Destructor>del_handler)
    
   
def he_close(he):
    """
         helium he_open function
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    return <int> che.he_close(handler)

def he_remove(he):
    """
         helium he_remove function
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    return <int> che.he_remove(handler)
 
# def he_stats(he,stats):
#     """
#          helium he_stats function
#           
#     """
#     handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
#     return <int> che.he_stats(handler,<che.he_stats*> stats)


def he_transaction(he):
    """
         helium he_open function
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    handler_out= che.he_transaction(handler)
    return PyCapsule_New(handler_out,'handler',<PyCapsule_Destructor>del_handler)

def he_commit(he):
    """
         helium he_stats function
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    return <int> che.he_commit(handler)

def he_discard(he):
    """
         helium he_discard function
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    return <int> che.he_discard(handler)



def he_update(he,item):
    """
         helium he_update function
        
    """
    return he_update_c(he,item)

  
cdef int he_update_c(he,item):
    """
         This function is to complete the he_update functionality in cdef.
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    heitem=get_che_he_item(item)
    return <int> che.he_update(handler,&heitem)

def he_insert(he,item):
    """
         helium he_update function
        
    """
    return he_insert_c(he,item)
  
cdef int he_insert_c(he,item):
    """
         This function is to complete the he_insert functionality in cdef.
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    heitem=get_che_he_item(item)
    return <int> che.he_insert(handler,&heitem)
      
def he_replace(he,item):
    """
         helium he_replace function
        
    """
    return he_replace_c(he,item)
  
cdef int he_replace_c(he,item):
    """
         This function is to complete the he_replace functionality in cdef.
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    heitem=get_che_he_item(item)
    return <int> che.he_replace(handler,&heitem)


def he_delete(he,item):
    """
         helium he_delete function
        
    """
    return he_delete_c(he,item)

cdef int he_delete_c(he,item):
    """
         This function is to complete the he_delete functionality in cdef.
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    heitem=get_che_he_item(item)
    return <int> che.he_delete(handler,&heitem)

def he_delete_lookup(he,item,off,len):
    """
         helium he_delete_lookup function
        
    """
    return he_delete_lookup_c(he,item,off,len)

cdef int he_delete_lookup_c(he,item,off,len):
    """
         This function is to complete the he_delete_lookup functionality in cdef.
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    heitem=get_che_he_item(item)
    return <int> che.he_delete_lookup(handler,&heitem,<size_t> off,<size_t> len)

def he_exists(he,item):
    """
         helium he_exists function
        
    """
    return he_exists_c(he,item)

cdef int he_exists_c(he,item):
    """
         This function is to complete the he_exists functionality in cdef.
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    heitem=get_che_he_item(item)
    return <int> che.he_exists(handler,&heitem)




def he_lookup(he,item,off,len):
    """
         helium he_exists function
        
    """
    return he_lookup_c(he,item,off,len)
  
cdef int he_lookup_c(he,item,off,len):
    """
         This function is to complete the he_lookup functionality in cdef.
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    heitem=get_che_he_item(item)
    value=<int> che.he_lookup(handler, &heitem,<size_t>off,<size_t>len)
    item.set_value(<bytes>heitem.key,100,<bytes>heitem.val,100)
    item.key_len=heitem.key_len
    item.val_len=heitem.val_len
    return value


def he_next(he,item,off,len):
    """
         helium he_next function
        
    """
    return he_next_c(he,item,off,len)
       
cdef int he_next_c(he,item,off,len):
    """
         This function is to complete the he_next functionality in cdef.
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    heitem=get_che_he_item(item)
    value=<int> che.he_next(handler, &heitem,<size_t>off,<size_t>len)
    item.key_len=heitem.key_len
    item.val_len=heitem.val_len
    
    return value
       
             
def he_prev(he,item,off,len):
    """
         helium he_prev function
        
    """
    return he_prev_c(he,item,off,len)
       
cdef int he_prev_c(he,item,off,len):
    """
         This function is to complete the he_prev functionality in cdef.
        
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    heitem=get_che_he_item(item)
    value=<int> che.he_prev(handler, &heitem,<size_t>off,<size_t>len)
    item.key_len=heitem.key_len
    item.val_len=heitem.val_len
    
    return value
    
 
def he_iterate(he,item,int cbf,arg):
    """
         helium he_iterate function
         
    """
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    return <int> che.he_iterate(handler,<che.he_iterate_cbf_t>cbf,<void *>arg)
  
 

    
def he_rename(he,name):
   
    handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
    return <int> che.he_rename(handler, <const char*> name)


def he_perror(s=None):
    """
         helium he_perror function
        
    """
    if (s):
        he_perror(bytes(s));
    else:
        he_perror();
  
 
def he_strerror(int err):
    """
         helium he_strerror function
        
    """
    return che.he_strerror(err)

def he_version(int major,int minor,int patch):
    """
         helium he_strerror function
        
    """
    return che.he_version(<int *>major, <int *>minor, <int *>patch)
 
          
# 
# cdef che.he_item gettestitem(he):
#     handler=<che.he_t> PyCapsule_GetPointer(he,'handler')
# 
#     cdef che.he_item item;
#     cdef void *key = malloc(17)
#     memcpy(key, "key val", 17)
#     
#     cdef void *val = malloc(17)
#     memcpy(val, "val val", 17)
#    
#  
#     item.key = key;
#     item.val = val;
#     item.key_len = <size_t> 17;
#     item.val_len = <size_t> 17;
#    
#     return item