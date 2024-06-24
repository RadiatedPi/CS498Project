int Get12PanelCh(float2 uv, int dmx)
{
    int startDMX = dmx;
    
    if(uv.x > (0.835) && uv.x < (0.865))
    {
        if(uv.y > 0.55 && uv.y < 0.575)      { return dmx; }
        else if(uv.y > 0.58 && uv.y < 0.605) { return dmx + 3; }
        else if(uv.y > 0.61 && uv.y < 0.635) { return dmx + 6; }
        else if(uv.y > 0.64 && uv.y < 0.665) { return dmx + 9; }
        else if(uv.y > 0.67 && uv.y < 0.695) { return dmx + 12; }
        else if(uv.y > 0.70 && uv.y < 0.725) { return dmx + 15; }
        else if(uv.y > 0.73 && uv.y < 0.755) { return dmx + 18; }
        else if(uv.y > 0.76 && uv.y < 0.785) { return dmx + 21; }
        else if(uv.y > 0.79 && uv.y < 0.815) { return dmx + 24; }
        else if(uv.y > 0.82 && uv.y < 0.845) { return dmx + 27; }
        else if(uv.y > 0.85 && uv.y < 0.875) { return dmx + 30; }
        else if(uv.y > 0.88 && uv.y < 0.905) { return dmx + 33; }
        else { return -2; }
    }
    else
    { return -2; }
}

int Get12BeamCh(float2 uv, int dmx)
{
    if(uv.x > (0.875) && uv.x < (0.905))
    {
        if(uv.y > 0.55 && uv.y < 0.575)      { return dmx; }
        else if(uv.y > 0.58 && uv.y < 0.605) { return dmx + 1; }
        else if(uv.y > 0.61 && uv.y < 0.635) { return dmx + 2; }
        else if(uv.y > 0.64 && uv.y < 0.665) { return dmx + 3; }
        else if(uv.y > 0.67 && uv.y < 0.695) { return dmx + 4; }
        else if(uv.y > 0.70 && uv.y < 0.725) { return dmx + 5; }
        else if(uv.y > 0.73 && uv.y < 0.755) { return dmx + 6; }
        else if(uv.y > 0.76 && uv.y < 0.785) { return dmx + 7; }
        else if(uv.y > 0.79 && uv.y < 0.815) { return dmx + 8; }
        else if(uv.y > 0.82 && uv.y < 0.845) { return dmx + 9; }
        else if(uv.y > 0.85 && uv.y < 0.875) { return dmx + 10; }
        else if(uv.y > 0.88 && uv.y < 0.905) { return dmx + 11; }
        else { return -2; }
    }
    else
    { return -2; }
}
half getValueAtCoords_Fixed(uint DMXChannel, sampler2D _Tex)
{
    uint universe = ceil(((int) DMXChannel)/512.0);
    int targetColor = getTargetRGBValue(universe);
    
    //DMXChannel = DMXChannel == 15.0 ? DMXChannel + 1 : DMXChannel;
    universe-=1;
    DMXChannel = targetColor > 0 ? DMXChannel - (((universe - (universe % 3)) * 512)) - (targetColor * 24) : DMXChannel;
    
    
    uint x = DMXChannel % 13; // starts at 1 ends at 13
    x = (x == 0.0) ? 13.0 : x;
    half y = DMXChannel / 13.0; // starts at 1 // doubles as sector
    y = frac(y)== 0.00000 ? y - 1 : y;
    if(x == 13.0) //for the 13th channel of each sector... Go down a sector for these DMX Channel Ranges...
    {
    
        //I don't know why, but we need this for some reason otherwise the 13th channel gets shifted around improperly.
        //I"m not sure how to express these exception ranges mathematically. Doing so would be much more cleaner though.
        y = DMXChannel >= 90 && DMXChannel <= 101 ? y - 1 : y;
        y = DMXChannel >= 160 && DMXChannel <= 205 ? y - 1 : y;
        y = DMXChannel >= 326 && DMXChannel <= 404 ? y - 1 : y;
        y = DMXChannel >= 676 && DMXChannel <= 819 ? y - 1 : y;
        y = DMXChannel >= 1339 ? y - 1 : y;
    }

    // y = (y > 6 && y < 31) && x == 13.0 ? y - 1 : y;
    
    float2 xyUV = _EnableCompatibilityMode == 1 ? LegacyRead(x-1.0,y) : IndustryRead(x,(y + 1.0));
        
    float4 uvcoords = float4(xyUV.x, xyUV.y, 0,0);
    half4 c = tex2Dlod(_Tex, uvcoords);
    half value = 0.0;
    
   if(getNineUniverseMode() && _EnableCompatibilityMode != 1)
   {
    value = c.r;
    value = IF(targetColor > 0, c.g, value);
    value = IF(targetColor > 1, c.b, value);
   }
   else
   {
        half3 cRGB = half3(c.r, c.g, c.b);
        value = LinearRgbToLuminance(cRGB);
    }
    value = LinearToGammaSpaceExact(value);
    return value;
}
float4 GetDMXColor_Fixed(uint DMXChannel)
{
    float redchannel = getValueAtCoords_Fixed(DMXChannel, _Udon_DMXGridRenderTexture);
    float greenchannel = getValueAtCoords_Fixed(DMXChannel + 1, _Udon_DMXGridRenderTexture);
    float bluechannel = getValueAtCoords_Fixed(DMXChannel + 2, _Udon_DMXGridRenderTexture);

    #if defined(PROJECTION_YES)
        redchannel = redchannel * _RedMultiplier;
        bluechannel = bluechannel * _BlueMultiplier;
        greenchannel = greenchannel * _GreenMultiplier;
    #endif

    //return IF(isOSC() == 1,lerp(fixed4(0,0,0,1), float4(redchannel,greenchannel,bluechannel,1), GetOSCIntensity(DMXChannel, _FixtureMaxIntensity)), float4(redchannel,greenchannel,bluechannel,1) * GetOSCIntensity(DMXChannel, _FixtureMaxIntensity));
    return float4(redchannel,greenchannel,bluechannel,1);
}


half GetStrobeOutput_Fixed(uint DMXChannel)
{
    
    // half phase = getValueAtCoordsRaw(DMXChannel + 6, _Udon_DMXGridStrobeTimer);
    // half status = getValueAtCoords(DMXChannel + 6, _Udon_DMXGridRenderTexture);

    half strobe = getValueAtCoords_Fixed(DMXChannel, _Udon_DMXGridStrobeOutput);
    // half strobe = (sin(phase));//Get sin wave
    // strobe = IF(strobe > 0.0, 1.0, 0.0);//turn to square wave
    //strobe = saturate(strobe);

    // strobe = IF(status > 0.2, strobe, 1); //minimum channel threshold set
    
    //check if we should even be strobing at all.
    strobe = IF(isDMX() == 1, strobe, 1);
    strobe = IF(isStrobe() == 1, strobe, 1);
    
    return strobe;

}