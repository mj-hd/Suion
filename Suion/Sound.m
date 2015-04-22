//
//  Sound.m
//  Suion
//
//  Created by mjhd on 2014/08/07.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import "Sound.h"

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>

@implementation Sound
{
    ALuint _source;
    ALuint _buffer;
}

static ALCcontext *context;
static ALCdevice *device;

+ (void)prepare {
    device = alcOpenDevice(NULL);
    if (device)
    {
        context = alcCreateContext(device, NULL); //コンテクストの作成
        alcMakeContextCurrent(context);                       //作成したコンテクストをカレントに設定
    }
}
+ (void)dealloc {
    // destroy the context
	alcDestroyContext(context);
	// close the device
	alcCloseDevice(device);
}

- (void)prepare {
    ALenum error;
    
    alGetError();              //Gen前に呼んでおく.errorをクリア.
    alGenBuffers(1, &_buffer); //曲データ１つにつきバッファ１つ．
    
    if ((error = alGetError()) != AL_NO_ERROR)
    {
        // エラー処理
        NSLog(@"alGenBuffers error");
        return;
    }
    
    alGetError(); // gen前.errorをクリア.
    alGenSources(1, &_source); //空間に配置する数の分生成する.
    
    if ((error = alGetError()) != AL_NO_ERROR)
    {
        // エラー処理
        NSLog(@"alGenSources error");
        return;
    }

    alSourcei( _source, AL_LOOPING , AL_TRUE);   // 繰り返し
    alSourcef( _source, AL_PITCH   , 1.0f);      // ピッチ
    alSourcef( _source, AL_GAIN    , 0.0f);    // 音量
    alSource3f(_source, AL_POSITION, 10, 20, 30); // 音源位置
    

    void    *data;
    ALenum  format;     // フォーマット
    ALsizei size;       // ファイルサイズ
    ALsizei freq;       // 周波数
    
    // bufferによみこみ
    CFURLRef fileURL = (__bridge CFURLRef)[NSURL fileURLWithPath:self.soundFile];
    data = MyGetOpenALAudioData(fileURL, &size, &format, &freq);  // sample内の読み込み関数を拾ってきた.
    alBufferDataStaticProc(_buffer, format, data, size, freq); // bufferにデータを登録
    
    // source と buffer の接続
    alSourcei(_source, AL_BUFFER, _buffer);
    
    // listerの設定
    ALfloat listenerPos[] = {0.0, 0.0, 0.0};
    ALfloat listenerVel[] = {0.0, 0.0, 0.0};
    ALfloat listenerOri[] = {0.0, 0.0, -1.0, 0.0, 1.0, 0.0}; //視線ベクトル．姿勢ベクトル
    
    alListenerfv(AL_POSITION, listenerPos);
    alListenerfv(AL_VELOCITY, listenerVel);
    alListenerfv(AL_ORIENTATION, listenerOri);
}

- (void)dealloc {
    alDeleteBuffers(1, &_buffer);
    alDeleteSources(1, &_source);
}

-(void)playLoop {
    alSourcePlay(_source);
}

- (void)stop {
    alSourceStop(_source);
}

- (void)setVolume:(float)volume {
    alSourcef( _source, AL_GAIN    , volume);
}

#pragma mark - from https://developer.apple.com/library/IOS/samplecode/oalTouch/Listings/Classes_MyOpenALSupport_c.html#//apple_ref/doc/uid/DTS40007769-Classes_MyOpenALSupport_c-DontLinkElementID_3

typedef ALvoid  AL_APIENTRY (*alBufferDataStaticProcPtr) (const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq);

ALvoid  alBufferDataStaticProc(const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq)

{
    
    static  alBufferDataStaticProcPtr   proc = NULL;
    
    
    
    if (proc == NULL) {
        
        proc = (alBufferDataStaticProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alBufferDataStatic");
        
    }
    
    
    
    if (proc)
        
        proc(bid, format, data, size, freq);
    
    
    
    return;
    
}



void* MyGetOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei*    outSampleRate)

{
    
    OSStatus                        err = noErr;
    
    SInt64                          theFileLengthInFrames = 0;
    
    AudioStreamBasicDescription     theFileFormat;
    
    UInt32                          thePropertySize = sizeof(theFileFormat);
    
    ExtAudioFileRef                 extRef = NULL;
    
    void*                           theData = NULL;
    
    AudioStreamBasicDescription     theOutputFormat;
    
    
    
    // Open a file with ExtAudioFileOpen()
    
    err = ExtAudioFileOpenURL(inFileURL, &extRef);
    
    if(err) { printf("MyGetOpenALAudioData: ExtAudioFileOpenURL FAILED, Error = %ld\n", err); goto Exit; }
    
    
    
    // Get the audio data format
    
    err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat);
    
    if(err) { printf("MyGetOpenALAudioData: ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = %ld\n", err); goto Exit; }
    
    if (theFileFormat.mChannelsPerFrame > 2)  { printf("MyGetOpenALAudioData - Unsupported Format, channel count is greater than stereo\n"); goto Exit;}
    
    
    
    // Set the client format to 16 bit signed integer (native-endian) data
    
    // Maintain the channel count and sample rate of the original source format
    
    theOutputFormat.mSampleRate = theFileFormat.mSampleRate;
    
    theOutputFormat.mChannelsPerFrame = theFileFormat.mChannelsPerFrame;
    
    
    
    theOutputFormat.mFormatID = kAudioFormatLinearPCM;
    
    theOutputFormat.mBytesPerPacket = 2 * theOutputFormat.mChannelsPerFrame;
    
    theOutputFormat.mFramesPerPacket = 1;
    
    theOutputFormat.mBytesPerFrame = 2 * theOutputFormat.mChannelsPerFrame;
    
    theOutputFormat.mBitsPerChannel = 16;
    
    theOutputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    
    
    
    // Set the desired client (output) data format
    
    err = ExtAudioFileSetProperty(extRef, kExtAudioFileProperty_ClientDataFormat, sizeof(theOutputFormat), &theOutputFormat);
    
    if(err) { printf("MyGetOpenALAudioData: ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) FAILED, Error = %ld\n", err); goto Exit; }
    
    
    
    // Get the total frame count
    
    thePropertySize = sizeof(theFileLengthInFrames);
    
    err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &thePropertySize, &theFileLengthInFrames);
    
    if(err) { printf("MyGetOpenALAudioData: ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) FAILED, Error = %ld\n", err); goto Exit; }
    
    
    
    // Read all the data into memory
    
    UInt32      dataSize = theFileLengthInFrames * theOutputFormat.mBytesPerFrame;;
    
    theData = malloc(dataSize);
    
    if (theData)
        
    {
        
        AudioBufferList     theDataBuffer;
        
        theDataBuffer.mNumberBuffers = 1;
        
        theDataBuffer.mBuffers[0].mDataByteSize = dataSize;
        
        theDataBuffer.mBuffers[0].mNumberChannels = theOutputFormat.mChannelsPerFrame;
        
        theDataBuffer.mBuffers[0].mData = theData;
        
        
        
        // Read the data into an AudioBufferList
        
        err = ExtAudioFileRead(extRef, (UInt32*)&theFileLengthInFrames, &theDataBuffer);
        
        if(err == noErr)
            
        {
            
            // success
            
            *outDataSize = (ALsizei)dataSize;
            
            *outDataFormat = (theOutputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
            
            *outSampleRate = (ALsizei)theOutputFormat.mSampleRate;
            
        }
        
        else
            
        { 
            
            // failure
            
            free (theData);
            
            theData = NULL; // make sure to return NULL
            
            printf("MyGetOpenALAudioData: ExtAudioFileRead FAILED, Error = %ld\n", err); goto Exit;
            
        }   
        
    }
    
    
    
Exit:
    
    // Dispose the ExtAudioFileRef, it is no longer needed
    
    if (extRef) ExtAudioFileDispose(extRef);
    
    return theData;
    
}

@end
