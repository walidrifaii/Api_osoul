import { Request, Response, NextFunction } from "express";
import jwt, { JwtPayload } from "jsonwebtoken";

export interface AuthRequest extends Request {
  user?: string | JwtPayload;
}

export const protect = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let token: string | undefined;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer ")
  ) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (!token) {
    res
      .status(401)
      .json({ message: "Not authorized, token missing", Authorized: false });
    return;
  }

  try {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
      res.status(500).json({ message: "JWT secret is not configured" });
      return;
    }
    const decoded = jwt.verify(token, secret);
    (req as AuthRequest).user = decoded;
    next();
  } catch (err) {
    res
      .status(401)
      .json({ message: "Not authorized, token invalid", Authorized: false });
    return;
  }
};
