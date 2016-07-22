'''
Created on 30 Jun 2016

@author: farshadjavadi
'''
import unittest
import os
import sys, getopt
import he
import string
import random



class test_system():
    
    DATASTORE_URL = '/tmp/4gb'
    DATASTORE_NAME = 'DATASTORE'
        
    def set_up(self):
        os.system("dd if=/dev/zero of={} bs=1k count=$((4*1024*1024))".format(self.DATASTORE_URL));
        print("datastore file created at he://./{}".format(self.DATASTORE_URL))
        pass


    def tear_down(self):
        os.system("rm -rf {}".format(self.DATASTORE_URL));
        pass


    def test_insert(self):
        print("Testing he_open, he_insert, he_close")
        print("Openning handler...")
        flags = he.HE_O_VOLUME_CREATE | he.HE_O_VOLUME_TRUNCATE | he.HE_O_CREATE | he.HE_O_TRUNCATE
        h = he.he_open("he://./{}".format(self.DATASTORE_URL), self.DATASTORE_NAME, flags,None)
   
        if (h is None):
            print("Handler failed to open %d".format(h))
            

        # generating 100 sample 
        print("Inserting 100 key,values...")
        he_item = he.he_item()
        insert_failed=False
        
        for i in range(0, 100):
            sample = self.data_generator(10)
            key=bytearray("{}_{}".format(sample, 'key').encode('UTF-8'))
            val=bytearray("{}_{}".format(sample, 'value').encode('UTF-8'))
            print("Inserting key {}  and value {} and key lenght is {}" .format(key,val,len(key)))
            he_item.set_value(key,len(key),val,len(val))
            ret_insert = he.he_insert(h, he_item);
          
            if (ret_insert !=0):
                insert_failed=True
                print("Insert failed with code {}".format(he.he_strerror(ret_insert)))
                exit
        
        if insert_failed==False:
            print("100 key, values inserted successfully.")
       
       
        ret_close = he.he_close(h);
        if (ret_close):
            print("closed failed with code {}".format(he.he_strerror(ret_close)))
            return ret_close
        print("Handler closed.")
        
        print("Tests for he_open, he_insert, he_close succeed.\n\n")

        return 0
    
    def test_insert_transaction(self):
        print("Testing he_transaction, he_update and he_commit")
        h = he.he_open("he://./{}".format(self.DATASTORE_URL), self.DATASTORE_NAME, 0,None)
        if (h is None):
            print("Handler failed to open %d".format(h))
        print("Handler opened.")

        h_transaction=he.he_transaction(h)
        print("he_transaction started")

        if (h_transaction is None):
            print("Transaction failed to open %d".format(h_transaction))
            return he.he_perror()
        # generating 100 sample 
        print("Inserting 10 key,values...")
        he_item = he.he_item()
        update_failed=False
        
        for i in range(0, 10):
            sample = self.data_generator(5)
            key=bytearray("{}_{}".format(sample, 'key_tr').encode('UTF-8'))
            val=bytearray("{}_{}".format(sample, 'value_tr').encode('UTF-8'))
            print("Inserting key {}  and value {} and key lenght is {}" .format(key,val,len(key)))
            he_item.set_value(key,len(key),val,len(val))
            ret_update = he.he_update(h_transaction, he_item);
            
            if (ret_update !=0):
                update_failed=True
                print("Insert failed with code {}".format(he.he_strerror(update_failed)))
                return update_failed
        if update_failed==False:
            print("10 key, values inserted successfully.")
       
        ret_comit=he.he_commit(h_transaction)
        if (ret_comit):
            print("Commit failed with code {}".format(he.he_strerror(ret_comit)))
            return ret_comit        
        print("Transaction committed.")
       
       
        
        ret_close = he.he_close(h);
        if (ret_close):
            print("closed failed with code {}".format(he.he_strerror(ret_close)))
            return ret_close
        
        print("Handler closed.")
        
        print("Tests for he_transaction, he_update and he_commit succeed.\n\n")
        return 0
    
    def test_next(self):
        print("Testing he_next")
        h = he.he_open("he://./{}".format(self.DATASTORE_URL), self.DATASTORE_NAME, 0,None)
   
        if (h is None):
            print("Handler failed to open %d".format(h))
            return he.he_perror()
        
        print("Handler opened.")
       
        he_item = he.he_item()
        
        print("A buffer of 100bytes created for key and value")
        he_item.set_value(bytearray(100),0,bytearray(100),0)

        ret_he_next=0
        while ret_he_next==0: 
            ret_he_next= he.he_next(h, he_item, 0, 100)
            if ret_he_next==0:
                print("key={}==>key_len={}==>val={}==>val_len={}".
                      format(he_item.key.decode("utf-8"),he_item.key_len,he_item.val.decode("utf-8"),he_item.val_len));
            elif (ret_he_next!=he.HE_ERR_ITEM_NOT_FOUND):
                print("he_next failed with code {} {}".format(ret_he_next,he.he_strerror(ret_he_next)))
                return ret_he_next
            else:
                print("No more item found")
            
        
        ret_close = he.he_close(h);
        if (ret_close):
            print("h_close failed with code {}".format(he.he_strerror(ret_close)))
            return ret_close
        print("Handler closed")
        
        print("he_next test succeed.\n\n")
        return 0
    
    def data_generator(self, size=6, chars=string.ascii_uppercase + string.digits):
        return ''.join(random.choice(chars) for _ in range(size))

if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    test_system=test_system()
    test_system.set_up()
    test_system.test_insert()
    test_system.test_insert_transaction()
    test_system.test_next()
    test_system.tear_down()
