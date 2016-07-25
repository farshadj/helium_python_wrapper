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



class Test_Helium_Methods(unittest.TestCase):
    
    DATASTORE_URL = '/tmp/4gb'
    DATASTORE_NAME = 'DATASTORE'
    DATASTORE_FLAGS = 15
    
    @classmethod
    def setUpClass(self):
        os.system("dd if=/dev/zero of={} bs=1k count=$((4*1024*1024))".format(self.DATASTORE_URL));
        print("datastore file created at he://./{}".format(self.DATASTORE_URL))
        pass

    @classmethod
    def tearDownClass(self):
        os.system("rm -rf {}".format(self.DATASTORE_URL));
        pass


    def test_write_data_no_transaction(self):
        print("Testing he_open, he_insert, he_close")
        flags = he.HE_O_VOLUME_CREATE | he.HE_O_VOLUME_TRUNCATE | he.HE_O_CREATE | he.HE_O_TRUNCATE
        h = he.he_open("he://./{}".format(self.DATASTORE_URL), self.DATASTORE_NAME, flags,None)
   
        if (h is None):
            self.assertFalse('Error: open function failed')            

        # generating 100 sample 
        he_item = he.he_item()
        insert_failed=False
        
        for i in range(0, 100):
            sample = self.data_generator(10)
            key=bytearray("{}_{}".format(sample, 'key').encode('UTF-8'))
            val=bytearray("{}_{}".format(sample, 'value').encode('UTF-8'))
            he_item.set_value(key,len(key),val,len(val))
            ret_insert = he.he_insert(h, he_item);
          
            self.assertEqual(ret_insert, 0, "he_insert failed with code {}".format(he.he_strerror(ret_insert)))

        
       
        ret_close = he.he_close(h);
        self.assertEqual(ret_close, 0, "he_close failed with code {}".format(he.he_strerror(ret_close)))

        pass
    
    def test_transaction_update_commit(self):
        print("Testing he_transaction, he_update and he_commit")
        flags = he.HE_O_VOLUME_CREATE | he.HE_O_CREATE

        h = he.he_open("he://./{}".format(self.DATASTORE_URL), self.DATASTORE_NAME, flags,None)
        if (h is None):
            self.assertFalse('Error: open function failed')            
        
        h_transaction=he.he_transaction(h)
     
        if (h_transaction is None):
            self.assertFalse('Error: open function failed')            
            
        # generating 100 sample 
        he_item = he.he_item()
        update_failed=False
        
        for i in range(0, 10):
            sample = self.data_generator(5)
            key=bytearray("{}_{}".format(sample, 'key_tr').encode('UTF-8'))
            val=bytearray("{}_{}".format(sample, 'value_tr').encode('UTF-8'))
            he_item.set_value(key,len(key),val,len(val))
            ret_update = he.he_update(h_transaction, he_item);
            
            self.assertEqual(ret_update, 0, "he_update failed with code {}".format(he.he_strerror(ret_update)))

       
        ret_comit=he.he_commit(h_transaction)
        self.assertEqual(ret_update, 0,"Commit failed with code {}".format(he.he_strerror(ret_comit)))

   
        
        ret_close = he.he_close(h);
        self.assertEqual(ret_close, 0, "he_close failed with code {}".format(he.he_strerror(ret_close)))
        pass
    
    
    def test_he_next(self):
        print("Testing he_next")
        flags = he.HE_O_VOLUME_CREATE | he.HE_O_CREATE
        h = he.he_open("he://./{}".format(self.DATASTORE_URL), self.DATASTORE_NAME, flags,None)
   
        if (h is None):
            self.assertFalse('Error: open function failed')            
        
        he_item = he.he_item()
        
        he_item.set_value(bytearray(100),0,bytearray(100),0)
        ret_he_next=0
        
        while ret_he_next==0: 
            ret_he_next= he.he_next(h, he_item, 0, 100)
            if (ret_he_next!=he.HE_ERR_ITEM_NOT_FOUND):
                self.assertFalse("he_next failed with {}".format(ret_he_next))
           
            
        
        ret_close = he.he_close(h);
        self.assertEqual(ret_close, 0, "he_close failed with code {}".format(he.he_strerror(ret_close)))

        pass
    
    

    def data_generator(self, size=6, chars=string.ascii_uppercase + string.digits):
        return ''.join(random.choice(chars) for _ in range(size))

if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
