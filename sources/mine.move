module tik_supply::mine {
    use sui::tx_context::{sender};
    use sui::clock::Clock;
    use sui::address;
    use sui::hash::blake2b256;
    use sui::dynamic_object_field;
    use sui::event;
    const EPOCH_REWARD:u128=277_777_778;
    const DECIMALS:u128=1_000_000_000_000;
    const BASESHARE:u64=10;
    const MAXLOCKDAYS:u64=60;
    const Ex_share:u64=1;


    const ERR_wait: u64=10;
    const ERR_DUPReg: u64 = 1000;
    const ERR_NOTReg: u64 = 1010;
    const ERR_EpochStp1: u64 = 1020;
    const ERR_EpochTimeout: u64 = 1021;
    const ERR_DUPhit: u64 = 1030;
    const ERR_LOCdays: u64 = 1040;
    const ERR_pass: u64 = 1050;



    public struct Miner has key {
        id: UID,
        Genesis:u64,
    }
    public struct MinerData has key,store {
        id: UID,
        reward_Epochs:vector<u64>,
    }
    public struct Rewardata has key,store {
        id: UID,
        share: u64,
        unlock:u64,
        eid:u64,
        euid:vector<u8>,
    }


    public struct Epochs has key {
        id: UID,
    }
    public struct EpochData has key,store {
        id: UID,
        shares_miners:vector<u64>,
    }
   
    public struct EpochRst has copy,drop {
        uid: vector<u8>,
        share:u64,
      
    }
   public struct RstEvet has copy, drop {
    epoch: u64,
    share:u64,
    ext_share:u64,
    unlock:u64,
    euid:vector<u8>,
  }
 
 
     fun init(  ctx: &mut TxContext) {      

            transfer::share_object(Epochs{
                 id: object::new(ctx),
            });

            transfer::share_object(Miner{
                 id: object::new(ctx),
                 Genesis: 1717977600,   //Genesis timestamp 
            });
      }


      public entry fun regist_miner(miner: &mut Miner,ctx: &mut TxContext)
      {
        assert!(!dynamic_object_field::exists_(&miner.id, ctx.sender()),ERR_DUPReg);
        if (!dynamic_object_field::exists_(&miner.id, ctx.sender()))
        {
            let minerdata = MinerData {
                id: object::new(ctx),
                reward_Epochs:vector::empty<u64>(),
                };
            dynamic_object_field::add(&mut miner.id, ctx.sender(),   minerdata); 

        }
      }

      fun hit(miner: &mut Miner, epochId:u64,share :u64, unlock:u64 ,euid:vector<u8> ,ctx: &mut TxContext)
      {
           assert!(dynamic_object_field::exists_(&miner.id, ctx.sender()),ERR_NOTReg);
          
           if (dynamic_object_field::exists_(&miner.id, ctx.sender()))
           {
 
                let rewardata=Rewardata{
                     id: object::new(ctx),
                     share:share, 
                     unlock:unlock,
                     eid:epochId,
                     euid:euid,
                };

                let minerdata_ref : &mut MinerData = dynamic_object_field::borrow_mut(&mut miner.id, ctx.sender());

                assert!(!dynamic_object_field::exists_(&minerdata_ref.id, epochId),ERR_DUPhit);

                minerdata_ref.reward_Epochs.push_back(epochId);
                dynamic_object_field::add(&mut minerdata_ref.id, epochId, rewardata); 
           }
      }

      public entry fun mine(miner: &mut Miner, epochs: &mut Epochs, epochId:u64, lockdays:u64,  clock: &Clock,ctx: &mut TxContext )
       {
          let currentepoch:u64 = clock.timestamp_ms() / 1000;
          assert!((currentepoch>=epochId),ERR_EpochStp1);
          assert!(currentepoch-epochId<=20 ,ERR_EpochTimeout);
          assert!(lockdays<=MAXLOCKDAYS ,ERR_LOCdays);
          assert!(currentepoch>miner.Genesis ,ERR_wait);
          
  
          let sender = tx_context::sender(ctx);
          let addresstep=   address::to_bytes(copy sender);
          let mut random_vector = vector::empty<u8>();
          vector::append(&mut random_vector, addresstep);
          vector::append(&mut random_vector, u64_to_ascii(epochId));
          let temp1 = blake2b256(&random_vector);
          let mut result: u128 = 0;
          let mut i: u64 = 0;
          while (i < 32) {
                result = (result << 8) | (*temp1.borrow(i) as u128); 
                i = i + 1; 
          };  


         let diff_epochId=epochId-30;
         let myshare=BASESHARE +lockdays ;
         let unlockTS=epochId+ lockdays  * 86400u64;

         let shares_miners=getorcreat_epoch_shares_miner(epochs, diff_epochId,myshare,ctx); 

         let miners=shares_miners[1];

         let diffa= (miners/1000+24) as u128 ;
         
         assert!(result % diffa== 0 ,ERR_pass);
         if ((result % diffa)== 0 )
         { 
           
             let eprst=  updateorcreat_epoch_shares_miner(epochs, epochId,myshare,ctx);
             hit(miner, epochId , myshare+eprst.share, unlockTS , eprst.uid  , ctx);
             event::emit(RstEvet { epoch: epochId , share: myshare+eprst.share , ext_share: eprst.share , unlock:lockdays,euid:eprst.uid});
         };

       }

        public(package) fun claim(miner: &mut Miner,epochs: &Epochs, clock: &Clock,ctx: &mut TxContext ) :u128
        {
             assert!(dynamic_object_field::exists_(&miner.id, ctx.sender()),2);
             let now = clock.timestamp_ms() / 1000;
             let flag_epoch = now-30;
            
             let minerdata_ref : &mut MinerData = dynamic_object_field::borrow_mut(&mut miner.id, ctx.sender());
             
             let mut reward_Epochs=minerdata_ref.reward_Epochs;
             let mut counter=minerdata_ref.reward_Epochs.length();
             let mut claimable:u128=0;
             let mut max_process=100;
             while  (counter > 0) {
                counter = counter - 1;
                let epid=minerdata_ref.reward_Epochs[counter] ;
                if ((epid as u128) <=(flag_epoch as u128))
                {
                     if (dynamic_object_field::exists_(&mut minerdata_ref.id, epid)){
                            let mut rewarddata : &mut Rewardata= dynamic_object_field::borrow_mut(&mut minerdata_ref.id, epid);
                            let unlock=rewarddata.unlock;
                            if (unlock<=now)
                            {
                                let epochdata_reference: &EpochData = dynamic_object_field::borrow(&epochs.id, epid);
                                let epoch_shares= (epochdata_reference.shares_miners[0] as u128) *DECIMALS;
                                let share=(rewarddata.share as u128) *DECIMALS;
                                let rwd=EPOCH_REWARD*share/epoch_shares;
                                claimable=claimable+rwd ;
                                vector::remove(&mut  minerdata_ref.reward_Epochs,counter);
                                let Rewardata{id: ruid, share:_, unlock:_, eid:_,euid:_} =   dynamic_object_field::remove<u64,Rewardata>(&mut  minerdata_ref.id, epid);
                                object::delete(ruid);
                                max_process=max_process-1;
                                if (max_process<=0)
                                {
                                    counter=0;
                                }

                            }
                     }else
                     {
                         vector::remove(&mut  minerdata_ref.reward_Epochs,counter);
                          max_process=max_process-1;
                          if (max_process<=0)
                          {
                                counter=0;
                          }
                     }
                   
                };
              
               
            };
            
            claimable
   
        }
       
      
       fun updateorcreat_epoch_shares_miner(epochs: &mut Epochs, eid:u64,share:u64,ctx: &mut TxContext) : EpochRst
       {
           let mut epsst:EpochRst =EpochRst{
            uid:vector::empty(),
            share:0,
           };
           if (dynamic_object_field::exists_(&epochs.id, eid)) {
                let epochdata_reference : &mut EpochData = dynamic_object_field::borrow_mut(&mut epochs.id, eid);
                epochdata_reference.shares_miners=vector[epochdata_reference.shares_miners[0]+share,epochdata_reference.shares_miners[1]+1];
                epsst.share=0;
                epsst.uid=  epochdata_reference.id.to_bytes();
                epsst  
           }
           else
            {
                
                creat_epoch_shares_miner(epochs, eid,share+Ex_share,ctx);
                let epochdata_reference : &EpochData = dynamic_object_field::borrow(&epochs.id, eid);
                 epsst.share=Ex_share;
                 epsst.uid=epochdata_reference.id.to_bytes();
                 epsst
            }  
       }
       fun getorcreat_epoch_shares_miner(epochs: &mut Epochs, eid:u64,share:u64,ctx: &mut TxContext): vector<u64>
       {
       
            if (dynamic_object_field::exists_(&epochs.id, eid)) {
                let epochdata_reference: &EpochData = dynamic_object_field::borrow(&epochs.id, eid);
             
                epochdata_reference.shares_miners
            }else
            {
                vector[0, 1]
            }            
       }

       fun creat_epoch_shares_miner(epochs: &mut Epochs, eid:u64,share:u64,ctx: &mut TxContext): vector<u64>
       {
                assert!(!dynamic_object_field::exists_(&epochs.id, eid),2);
                let epochdata = EpochData {
                    id: object::new(ctx),
                    shares_miners:vector[share, 1],
                };
                let rst=epochdata.shares_miners;
                dynamic_object_field::add(&mut epochs.id, eid,   epochdata); 
                rst
       }

  


       fun u64_to_ascii(mut num: u64): vector<u8>
       {
      if (num == 0) {
          return b"0"
      };
      let mut bytes = vector::empty<u8>();
      while (num > 0) {
          let remainder = num % 10; // get the last digit
          num = num / 10; // remove the last digit
          vector::push_back(&mut bytes, (remainder as u8) + 48); // ASCII value of 0 is 48
      };
      vector::reverse(&mut bytes);
      return bytes
  }
}
