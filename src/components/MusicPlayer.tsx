import { useState, useRef, useEffect } from "react";
import { Play, Pause, SkipBack, SkipForward, Volume2, Heart, Shuffle, Repeat } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Slider } from "@/components/ui/slider";
import { Card } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";

interface Track {
  id: string;
  title: string;
  artist: string;
  album: string;
  duration: number;
  cover: string;
  url?: string;
}

interface MusicPlayerProps {
  currentTrack?: Track;
  isPlaying: boolean;
  onPlayPause: () => void;
  onNext: () => void;
  onPrevious: () => void;
  onSeek?: (time: number) => void;
}

export function MusicPlayer({ 
  currentTrack, 
  isPlaying, 
  onPlayPause, 
  onNext, 
  onPrevious,
  onSeek
}: MusicPlayerProps) {
  const [currentTime, setCurrentTime] = useState(0);
  const [volume, setVolume] = useState([75]);
  const [isShuffle, setIsShuffle] = useState(false);
  const [repeatMode, setRepeatMode] = useState<'off' | 'all' | 'one'>('off');
  const [isLiked, setIsLiked] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const audioRef = useRef<HTMLAudioElement>(null);
  const { toast } = useToast();

  // Audio element effects
  useEffect(() => {
    const audio = audioRef.current;
    if (!audio || !currentTrack?.url) return;

    const handleTimeUpdate = () => setCurrentTime(audio.currentTime);
    const handleLoadStart = () => setIsLoading(true);
    const handleCanPlay = () => setIsLoading(false);
    const handleError = () => {
      setIsLoading(false);
      toast({
        title: "Playback Error",
        description: "Unable to play this track",
        variant: "destructive"
      });
    };

    audio.addEventListener('timeupdate', handleTimeUpdate);
    audio.addEventListener('loadstart', handleLoadStart);
    audio.addEventListener('canplay', handleCanPlay);
    audio.addEventListener('error', handleError);
    audio.addEventListener('ended', onNext);

    return () => {
      audio.removeEventListener('timeupdate', handleTimeUpdate);
      audio.removeEventListener('loadstart', handleLoadStart);
      audio.removeEventListener('canplay', handleCanPlay);
      audio.removeEventListener('error', handleError);
      audio.removeEventListener('ended', onNext);
    };
  }, [currentTrack, onNext, toast]);

  // Play/pause control
  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    if (isPlaying) {
      audio.play().catch(console.error);
    } else {
      audio.pause();
    }
  }, [isPlaying]);

  // Volume control
  useEffect(() => {
    const audio = audioRef.current;
    if (audio) {
      audio.volume = volume[0] / 100;
    }
  }, [volume]);

  // Track change
  useEffect(() => {
    const audio = audioRef.current;
    if (audio && currentTrack?.url) {
      audio.src = currentTrack.url;
      setCurrentTime(0);
    }
  }, [currentTrack]);

  const handleSeek = (value: number[]) => {
    const newTime = value[0];
    setCurrentTime(newTime);
    if (audioRef.current) {
      audioRef.current.currentTime = newTime;
    }
    onSeek?.(newTime);
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  if (!currentTrack) {
    return (
      <Card className="fixed bottom-0 left-0 right-0 h-20 bg-card/95 backdrop-blur-lg border-t border-glass z-50">
        <div className="flex items-center justify-center h-full">
          <p className="text-muted-foreground">No track selected</p>
        </div>
      </Card>
    );
  }

  return (
    <>
      {/* Hidden audio element for playback */}
      <audio ref={audioRef} preload="metadata" />
      
      <Card className="fixed bottom-0 left-0 right-0 h-24 bg-card/95 backdrop-blur-lg border-t border-glass z-50">
      <div className="flex items-center justify-between h-full px-4">
        {/* Track Info */}
        <div className="flex items-center gap-3 min-w-0 w-1/4">
          <img 
            src={currentTrack.cover} 
            alt={currentTrack.album}
            className="w-14 h-14 rounded-lg object-cover"
          />
          <div className="min-w-0">
            <h4 className="font-medium text-foreground truncate">{currentTrack.title}</h4>
            <p className="text-sm text-muted-foreground truncate">{currentTrack.artist}</p>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setIsLiked(!isLiked)}
            className="shrink-0"
          >
            <Heart className={`h-4 w-4 ${isLiked ? 'fill-music-primary text-music-primary' : ''}`} />
          </Button>
        </div>

        {/* Player Controls */}
        <div className="flex flex-col items-center gap-2 w-1/2 max-w-md">
          <div className="flex items-center gap-2">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setIsShuffle(!isShuffle)}
              className={isShuffle ? 'text-music-primary' : ''}
            >
              <Shuffle className="h-4 w-4" />
            </Button>
            
            <Button variant="ghost" size="sm" onClick={onPrevious}>
              <SkipBack className="h-4 w-4" />
            </Button>
            
            <Button 
              variant="ghost" 
              size="sm" 
              onClick={onPlayPause}
              className="h-10 w-10 rounded-full bg-music-primary hover:bg-music-primary/90 text-white"
            >
              {isPlaying ? <Pause className="h-5 w-5" /> : <Play className="h-5 w-5 ml-0.5" />}
            </Button>
            
            <Button variant="ghost" size="sm" onClick={onNext}>
              <SkipForward className="h-4 w-4" />
            </Button>
            
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setRepeatMode(repeatMode === 'off' ? 'all' : repeatMode === 'all' ? 'one' : 'off')}
              className={repeatMode !== 'off' ? 'text-music-primary' : ''}
            >
              <Repeat className="h-4 w-4" />
              {repeatMode === 'one' && <span className="text-xs ml-1">1</span>}
            </Button>
          </div>

          {/* Progress Bar */}
          <div className="flex items-center gap-2 w-full">
            <span className="text-xs text-muted-foreground w-10">
              {formatTime(currentTime)}
            </span>
            <Slider
              value={[currentTime]}
              max={currentTrack.duration}
              step={1}
              onValueChange={handleSeek}
              className="flex-1"
            />
            <span className="text-xs text-muted-foreground w-10">
              {formatTime(currentTrack.duration)}
            </span>
          </div>
        </div>

        {/* Volume Control */}
        <div className="flex items-center gap-2 w-1/4 justify-end">
          <Volume2 className="h-4 w-4 text-muted-foreground" />
          <Slider
            value={volume}
            max={100}
            step={1}
            onValueChange={setVolume}
            className="w-24"
          />
        </div>
      </div>
    </Card>
    </>
  );
}