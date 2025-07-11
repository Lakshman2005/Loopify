import { Play, Pause, Heart, MoreHorizontal } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

interface Track {
  id: string;
  title: string;
  artist: string;
  album: string;
  duration: number;
  cover: string;
  url?: string;
}

interface TrackCardProps {
  track: Track;
  isPlaying?: boolean;
  onPlay: (track: Track) => void;
  onAddToPlaylist?: (track: Track) => void;
  showCover?: boolean;
  index?: number;
}

export function TrackCard({ 
  track, 
  isPlaying = false, 
  onPlay, 
  onAddToPlaylist,
  showCover = true,
  index 
}: TrackCardProps) {
  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <Card className="group hover:bg-accent/50 transition-all duration-200 p-3 cursor-pointer">
      <div className="flex items-center gap-3">
        {/* Track Number or Play Button */}
        <div className="w-6 flex justify-center">
          {index !== undefined ? (
            <span className="text-sm text-muted-foreground group-hover:hidden">
              {index + 1}
            </span>
          ) : null}
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onPlay(track)}
            className={`w-6 h-6 p-0 ${index !== undefined ? 'hidden group-hover:flex' : 'flex'} items-center justify-center hover:scale-110 transition-transform`}
          >
            {isPlaying ? (
              <Pause className="h-4 w-4 text-music-primary" />
            ) : (
              <Play className="h-4 w-4" />
            )}
          </Button>
        </div>

        {/* Album Cover */}
        {showCover && (
          <img 
            src={track.cover} 
            alt={track.album}
            className="w-12 h-12 rounded-md object-cover"
          />
        )}

        {/* Track Info */}
        <div className="flex-1 min-w-0">
          <h4 className={`font-medium truncate ${isPlaying ? 'text-music-primary' : 'text-foreground'}`}>
            {track.title}
          </h4>
          <p className="text-sm text-muted-foreground truncate">{track.artist}</p>
        </div>

        {/* Album Name (hidden on mobile) */}
        <div className="hidden md:block flex-1 min-w-0">
          <p className="text-sm text-muted-foreground truncate">{track.album}</p>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-2">
          {/* Like Button */}
          <Button
            variant="ghost"
            size="sm"
            className="opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <Heart className="h-4 w-4" />
          </Button>

          {/* Duration */}
          <span className="text-sm text-muted-foreground w-12 text-right">
            {formatDuration(track.duration)}
          </span>

          {/* More Options */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="sm"
                className="opacity-0 group-hover:opacity-100 transition-opacity"
              >
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={() => onAddToPlaylist?.(track)}>
                Add to Playlist
              </DropdownMenuItem>
              <DropdownMenuItem>Add to Queue</DropdownMenuItem>
              <DropdownMenuItem>Share</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </Card>
  );
}