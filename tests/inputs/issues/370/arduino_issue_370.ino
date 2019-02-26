// file contains 0xA0 characters which defeats the counter unless stripped

//Only do this if PC (Kenwood power setting) has changed:
      // Extract power setting
       if (new_PC==true){
        String power_value=(store_PC.substring(2,5));  //extract the power value from the PC response string
        KEN_pwr = power_value.toInt();                 //then convert that extracted string to integer
      //  Serial.print("Integer power = ");
      //  Serial.println(KEN_pwr);
       }
