import { Play } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";

interface Album {
  id: string;
  title: string;
  artist: string;
  cover: string;
  year?: number;
  trackCount?: number;
}

interface AlbumCardProps {
  album: Album;
  onPlay: (album: Album) => void;
  size?: "sm" | "md" | "lg";
}

export function AlbumCard({ album, onPlay, size = "md" }: AlbumCardProps) {
  const sizeClasses = {
    sm: "w-32 h-32",
    md: "w-40 h-40",
    lg: "w-48 h-48"
  };

  return (
    <Card className="group p-4 hover:bg-accent/50 transition-all duration-300 cursor-pointer hover:shadow-glow">
      <div className="space-y-3">
        {/* Album Cover with Play Button */}
        <div className="relative">
          <img 
            src={album.cover} 
            alt={album.title}
            className={`${sizeClasses[size]} rounded-lg object-cover transition-transform group-hover:scale-105`}
          />
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onPlay(album)}
            className="absolute bottom-2 right-2 w-12 h-12 rounded-full bg-music-primary hover:bg-music-primary/90 text-white opacity-0 group-hover:opacity-100 transition-all duration-200 hover:scale-110 shadow-lg"
          >
            <Play className="h-5 w-5 ml-0.5" />
          </Button>
        </div>

        {/* Album Info */}
        <div className="space-y-1">
          <h3 className="font-semibold text-foreground truncate group-hover:text-music-primary transition-colors">
            {album.title}
          </h3>
          <p className="text-sm text-muted-foreground truncate">{album.artist}</p>
          {album.year && (
            <p className="text-xs text-muted-foreground">{album.year}</p>
          )}
        </div>
      </div>
    </Card>
  );
}